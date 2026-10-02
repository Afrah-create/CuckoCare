-- Vet GPS on profiles, farmer-directed routing, directory RPC, inbox filtering.

alter table public.vet_profiles
  add column if not exists latitude double precision,
  add column if not exists longitude double precision,
  add column if not exists location_accuracy_m real,
  add column if not exists location_captured_at timestamptz,
  add column if not exists district text;

alter table public.vet_assistance_requests
  add column if not exists requested_vet_user_id uuid references auth.users (id);

create index if not exists vet_requests_requested_vet_idx
  on public.vet_assistance_requests (requested_vet_user_id, status);

update public.sync_table_config
set writable_columns = array[
  'id','farm_id','batch_id','health_record_id','service_type','status',
  'share_location','priority','farmer_notes','requested_vet_user_id','created_at'
]
where table_name = 'vet_assistance_requests';

drop policy if exists vet_profiles_select_farmer on public.vet_profiles;
create policy vet_profiles_select_farmer on public.vet_profiles
  for select to authenticated
  using (
    user_id = (select auth.uid())
    or public.current_app_role() = 'farmer'
  );

create or replace function public.save_vet_location(
  p_latitude double precision,
  p_longitude double precision,
  p_accuracy_m real default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  update public.vet_profiles
  set
    latitude = p_latitude,
    longitude = p_longitude,
    location_accuracy_m = p_accuracy_m,
    location_captured_at = now(),
    updated_at = now()
  where user_id = auth.uid();

  if not found then
    insert into public.vet_profiles (user_id, latitude, longitude, location_accuracy_m, location_captured_at)
    values (auth.uid(), p_latitude, p_longitude, p_accuracy_m, now());
  end if;

  return jsonb_build_object(
    'latitude', p_latitude,
    'longitude', p_longitude,
    'location_accuracy_m', p_accuracy_m,
    'location_captured_at', now()
  );
end;
$$;

grant execute on function public.save_vet_location(double precision, double precision, real) to authenticated;

create or replace function public.list_available_vets(p_farm_id uuid default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_farm_lat double precision;
  v_farm_lon double precision;
  v_rows jsonb;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if public.current_app_role() <> 'farmer' then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_farm_id is not null then
    select f.latitude, f.longitude into v_farm_lat, v_farm_lon
    from public.farms f
    where f.id = p_farm_id and f.deleted_at is null;
  end if;

  select coalesce(
    jsonb_agg(entry order by (entry->>'distance_km')::double precision nulls last),
    '[]'::jsonb
  )
  into v_rows
  from (
    select jsonb_build_object(
      'user_id', v.user_id,
      'display_name', coalesce(v.display_name, p.display_name, 'Veterinarian'),
      'organization', v.organization,
      'district', v.district,
      'offers_consultation', v.offers_consultation,
      'offers_farm_visit', v.offers_farm_visit,
      'latitude', v.latitude,
      'longitude', v.longitude,
      'distance_km', case
        when v_farm_lat is not null and v_farm_lon is not null
          and v.latitude is not null and v.longitude is not null then
          (
            6371 * acos(
              least(1.0, greatest(-1.0,
                cos(radians(v_farm_lat)) * cos(radians(v.latitude))
                * cos(radians(v.longitude) - radians(v_farm_lon))
                + sin(radians(v_farm_lat)) * sin(radians(v.latitude))
              ))
            )
          )
        else null
      end
    ) as entry
    from public.vet_profiles v
    join public.profiles p on p.user_id = v.user_id and p.app_role = 'vet'
  ) ranked;

  return jsonb_build_object('vets', v_rows);
end;
$$;

grant execute on function public.list_available_vets(uuid) to authenticated;

-- Inbox: broadcast (no requested vet) or directed to this vet.
create or replace function public.vet_inbox(p_limit int default 50)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit int := least(greatest(coalesce(p_limit, 50), 1), 200);
  v_rows jsonb;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  select coalesce(jsonb_agg(row order by row->>'created_at' desc), '[]'::jsonb)
  into v_rows
  from (
    select jsonb_build_object(
      'id', r.id,
      'farm_id', r.farm_id,
      'batch_id', r.batch_id,
      'health_record_id', r.health_record_id,
      'service_type', r.service_type,
      'status', r.status,
      'share_location', r.share_location,
      'priority', r.priority,
      'farmer_notes', r.farmer_notes,
      'created_at', r.created_at,
      'requested_vet_user_id', r.requested_vet_user_id,
      'assigned_vet_user_id', r.assigned_vet_user_id,
      'summary', h.summary,
      'affected_bird_count', h.affected_bird_count,
      'symptoms', h.symptoms,
      'photo_object_keys', h.photo_object_keys,
      'farm_name', f.name,
      'farm_district', f.district,
      'farm_village', f.village,
      'farm_latitude', f.latitude,
      'farm_longitude', f.longitude,
      'distance_km', case
        when f.latitude is not null and f.longitude is not null
          and vp.latitude is not null and vp.longitude is not null then
          (
            6371 * acos(
              least(1.0, greatest(-1.0,
                cos(radians(vp.latitude)) * cos(radians(f.latitude))
                * cos(radians(f.longitude) - radians(vp.longitude))
                + sin(radians(vp.latitude)) * sin(radians(f.latitude))
              ))
            )
          )
        else null
      end
    ) as row
    from public.vet_assistance_requests r
    join public.health_records h on h.id = r.health_record_id and h.deleted_at is null
    join public.farms f on f.id = r.farm_id and f.deleted_at is null
    left join public.vet_profiles vp on vp.user_id = auth.uid()
    where r.deleted_at is null
      and r.status in ('submitted', 'received', 'accepted', 'in_progress')
      and (
        r.requested_vet_user_id is null
        or r.requested_vet_user_id = auth.uid()
      )
    order by r.created_at desc
    limit v_limit
  ) s;

  return jsonb_build_object('requests', v_rows);
end;
$$;
