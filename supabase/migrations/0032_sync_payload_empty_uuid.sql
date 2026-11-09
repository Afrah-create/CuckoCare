-- Empty JSON strings must not be cast to uuid (22P02).
-- apply_farmer_case_read_state used (payload->>'last_read_message_id')::uuid.

create or replace function public.apply_farmer_case_read_state(p_payload jsonb, p_uid uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_request_id uuid := nullif(btrim(p_payload->>'request_id'), '')::uuid;
  v_read_at timestamptz := coalesce((p_payload->>'last_read_at')::timestamptz, now());
  v_row public.case_read_state;
  v_farm uuid;
begin
  if v_request_id is null then
    raise exception 'invalid_input' using errcode = '22P02';
  end if;
  if not public.can_view_case_request(v_request_id) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if not public.is_farm_member(
    (select farm_id from public.vet_assistance_requests where id = v_request_id)
  ) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select farm_id into v_farm from public.vet_assistance_requests where id = v_request_id;
  insert into public.case_read_state (
    request_id, user_id, farm_id, last_read_at, last_read_message_id, muted,
    created_at, updated_at
  ) values (
    v_request_id,
    p_uid,
    v_farm,
    v_read_at,
    nullif(btrim(p_payload->>'last_read_message_id'), '')::uuid,
    coalesce((p_payload->>'muted')::boolean, false),
    now(),
    now()
  )
  on conflict (request_id, user_id) do update set
    last_read_at = case
      when excluded.last_read_at > case_read_state.last_read_at
      then excluded.last_read_at
      else case_read_state.last_read_at
    end,
    last_read_message_id = case
      when excluded.last_read_at > case_read_state.last_read_at
      then excluded.last_read_message_id
      else case_read_state.last_read_message_id
    end,
    muted = excluded.muted,
    updated_at = now()
  returning * into v_row;
  return to_jsonb(v_row);
end;
$$;
