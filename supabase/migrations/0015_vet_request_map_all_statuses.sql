-- Include completed (and in-progress) visits on the vet map, not only open queue.

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
