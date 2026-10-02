-- Farmers only for save_farm_profile (vets use vet_profiles, not farms).

create or replace function public.save_farm_profile(
  p_name text,
  p_district text,
  p_village text,
  p_phone text,
  p_alt_phone text default null,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_farm_id uuid;
  v_location text;
begin
  if v_user is null then
    raise exception 'not authenticated';
  end if;

  if public.current_app_role() <> 'farmer' then
    raise exception 'only farmers can save a farm profile' using errcode = '42501';
  end if;

  if nullif(trim(p_name), '') is null then
    raise exception 'farm name is required';
  end if;
  if nullif(trim(p_district), '') is null then
    raise exception 'district is required';
  end if;
  if nullif(trim(p_village), '') is null then
    raise exception 'village is required';
  end if;
  if nullif(trim(p_phone), '') is null then
    raise exception 'phone is required';
  end if;

  v_location := trim(p_district) || ', ' || trim(p_village);

  select f.id into v_farm_id
  from public.farms f
  join public.farm_members fm on fm.farm_id = f.id and fm.deleted_at is null
  where fm.user_id = v_user and fm.role = 'owner'
  order by f.created_at
  limit 1;

  if v_farm_id is null then
    v_farm_id := gen_random_uuid();
    insert into public.farms (
      id, farm_id, name, location, district, village, phone, alt_phone, notes,
      created_by, profile_completed_at
    )
    values (
      v_farm_id,
      v_farm_id,
      trim(p_name),
      v_location,
      trim(p_district),
      trim(p_village),
      trim(p_phone),
      nullif(trim(coalesce(p_alt_phone, '')), ''),
      nullif(trim(coalesce(p_notes, '')), ''),
      v_user,
      now()
    );
    insert into public.farm_members (id, farm_id, user_id, role)
    values (gen_random_uuid(), v_farm_id, v_user, 'owner');
  else
    update public.farms
    set
      name = trim(p_name),
      location = v_location,
      district = trim(p_district),
      village = trim(p_village),
      phone = trim(p_phone),
      alt_phone = nullif(trim(coalesce(p_alt_phone, '')), ''),
      notes = nullif(trim(coalesce(p_notes, '')), ''),
      profile_completed_at = now(),
      updated_at = now()
    where id = v_farm_id;
  end if;

  perform public.bump_sync_server_version(v_farm_id::text);
  return v_farm_id;
end;
$$;

grant execute on function public.save_farm_profile(text, text, text, text, text, text) to authenticated;
