-- Incident photos (Supabase Storage) + vet map RPC with farm GPS + health context.

-- ---------------------------------------------------------------------------
-- Health records: photo object keys (storage paths, synced)
-- ---------------------------------------------------------------------------

alter table public.health_records
  add column if not exists photo_object_keys jsonb not null default '[]'::jsonb;

alter table public.health_records drop constraint if exists health_records_record_kind_check;
alter table public.health_records add constraint health_records_record_kind_check
  check (record_kind in ('observation', 'incident', 'follow_up', 'vet_consultation'));

update public.sync_table_config
set writable_columns = array[
  'id','farm_id','batch_id','occurred_on','summary','notes','created_at',
  'affected_bird_count','symptoms','record_kind','photo_object_keys'
]
where table_name = 'health_records';

-- ---------------------------------------------------------------------------
-- Storage bucket: health-incident-images (private)
-- Object path: {user_id}/{health_record_id}/{uuid}.jpg
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'health-incident-images',
  'health-incident-images',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists health_incident_images_insert on storage.objects;
drop policy if exists health_incident_images_select_owner on storage.objects;
drop policy if exists health_incident_images_select_vet on storage.objects;

create policy health_incident_images_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'health-incident-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy health_incident_images_select_owner on storage.objects
  for select to authenticated
  using (
    bucket_id = 'health-incident-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy health_incident_images_select_vet on storage.objects
  for select to authenticated
  using (
    bucket_id = 'health-incident-images'
    and public.is_vet()
  );

-- ---------------------------------------------------------------------------
-- Vet map: open requests with location + incident details
-- ---------------------------------------------------------------------------

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
    order by r.created_at desc
    limit v_limit
  ) s;

  return jsonb_build_object('requests', v_rows);
end;
$$;

grant execute on function public.vet_request_map(int) to authenticated;

-- Richer vet inbox (incident summary + symptoms from health record).
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
      'summary', h.summary,
      'affected_bird_count', h.affected_bird_count,
      'symptoms', h.symptoms,
      'photo_object_keys', h.photo_object_keys
    ) as row
    from public.vet_assistance_requests r
    join public.health_records h on h.id = r.health_record_id and h.deleted_at is null
    where r.deleted_at is null
      and r.status in ('submitted', 'received', 'accepted', 'in_progress')
    order by r.created_at desc
    limit v_limit
  ) s;

  return jsonb_build_object('requests', v_rows);
end;
$$;
