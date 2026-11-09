-- 0030: Health incidents must persist and still appear on the vet portal.
-- health_records was append_only, so the photo follow-up upsert was a no-op and
-- a rejected first insert (including record_kind = incident) never retried.
-- Vet inbox/map INNER JOIN health_records hid any request whose health row
-- did not land. Rollback: set kind back to append_only; restore INNER JOIN
-- functions from 0013 / 0015.

alter table public.health_records drop constraint if exists health_records_record_kind_check;
alter table public.health_records add constraint health_records_record_kind_check
  check (record_kind in ('observation', 'incident', 'follow_up', 'vet_consultation'));

update public.sync_table_config
set kind = 'mutable',
    writable_columns = array[
      'id','farm_id','batch_id','occurred_on','summary','notes','created_at',
      'affected_bird_count','symptoms','record_kind','photo_object_keys','deleted_at'
    ]
where table_name = 'health_records';

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
      'summary', coalesce(h.summary, r.farmer_notes, 'Health incident'),
      'affected_bird_count', h.affected_bird_count,
      'symptoms', coalesce(h.symptoms, '[]'::jsonb),
      'photo_object_keys', coalesce(h.photo_object_keys, '[]'::jsonb),
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
    left join public.health_records h
      on h.id = r.health_record_id and h.deleted_at is null
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
      'summary', coalesce(h.summary, r.farmer_notes, 'Health incident'),
      'affected_bird_count', h.affected_bird_count,
      'symptoms', coalesce(h.symptoms, '[]'::jsonb),
      'photo_object_keys', coalesce(h.photo_object_keys, '[]'::jsonb),
      'farm_name', f.name,
      'farm_district', f.district,
      'farm_village', f.village,
      'latitude', f.latitude,
      'longitude', f.longitude
    ) as row
    from public.vet_assistance_requests r
    left join public.health_records h
      on h.id = r.health_record_id and h.deleted_at is null
    join public.farms f on f.id = r.farm_id and f.deleted_at is null
    where r.deleted_at is null
      and r.status in (
        'submitted',
        'received',
        'accepted',
        'in_progress',
        'completed'
      )
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

grant execute on function public.vet_inbox(int) to authenticated;
grant execute on function public.vet_request_map(int) to authenticated;
