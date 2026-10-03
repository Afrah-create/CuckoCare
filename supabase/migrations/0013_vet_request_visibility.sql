
create or replace function public.vet_can_view_request(
  p_assigned uuid,
  p_requested uuid,
  p_viewer uuid
)
returns boolean
language sql
immutable
as $$
  select
    (p_assigned is not null and p_assigned = p_viewer)
    or (
      p_assigned is null
      and (p_requested is null or p_requested = p_viewer)
    );
$$;

create or replace function public.vet_set_request_status(
  p_request_id uuid,
  p_status text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.vet_assistance_requests;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_status not in ('received', 'accepted', 'declined', 'in_progress', 'completed') then
    raise exception 'invalid status';
  end if;

  update public.vet_assistance_requests
  set
    status = p_status,
    assigned_vet_user_id = case
      when p_status in ('accepted', 'in_progress', 'completed') then
        coalesce(assigned_vet_user_id, auth.uid())
      else assigned_vet_user_id
    end,
    updated_at = now()
  where id = p_request_id
    and deleted_at is null
    and public.vet_can_view_request(
      assigned_vet_user_id,
      requested_vet_user_id,
      auth.uid()
    )
    and (
      assigned_vet_user_id is null
      or assigned_vet_user_id = auth.uid()
      or p_status = 'declined'
    )
  returning * into v_row;

  if v_row.id is null then
    raise exception 'request not found or not available';
  end if;

  return to_jsonb(v_row);
end;
$$;

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
      and public.vet_can_view_request(
        r.assigned_vet_user_id,
        r.requested_vet_user_id,
        auth.uid()
      )
    order by r.created_at desc
    limit v_limit
  ) s;

  return jsonb_build_object('requests', v_rows);
end;
$$;

create or replace function public.vet_request_map(p_limit int default 100)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit int := least(greatest(coalesce(p_limit, 100), 1), 200);
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
      'priority', r.priority,
      'share_location', r.share_location,
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
      'latitude', f.latitude,
      'longitude', f.longitude
    ) as row
    from public.vet_assistance_requests r
    join public.health_records h on h.id = r.health_record_id and h.deleted_at is null
    join public.farms f on f.id = r.farm_id and f.deleted_at is null
    where r.deleted_at is null
      and r.status in ('submitted', 'received', 'accepted', 'in_progress')
      and public.vet_can_view_request(
        r.assigned_vet_user_id,
        r.requested_vet_user_id,
        auth.uid()
      )
    order by r.created_at desc
    limit v_limit
  ) s;

  return jsonb_build_object('requests', v_rows);
end;
$$;

grant execute on function public.vet_can_view_request(uuid, uuid, uuid) to authenticated;
grant execute on function public.vet_set_request_status(uuid, text) to authenticated;
grant execute on function public.vet_inbox(int) to authenticated;
grant execute on function public.vet_request_map(int) to authenticated;
