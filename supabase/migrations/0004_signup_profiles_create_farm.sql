-- Sign-up without a farm; profile + farm created in a later step.

-- ---------------------------------------------------------------------------
-- Profiles (auth.users companion)
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
  for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
  for insert to authenticated
  with check (user_id = (select auth.uid()));

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (user_id, display_name, phone)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'display_name',
      nullif(split_part(coalesce(new.email, ''), '@', 1), '')
    ),
    new.phone
  )
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Create first farm (post sign-up onboarding)
-- ---------------------------------------------------------------------------

create or replace function public.create_farm(
  p_name text,
  p_location text,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_farm_id uuid := gen_random_uuid();
begin
  if v_user is null then
    raise exception 'not authenticated';
  end if;

  if nullif(trim(p_name), '') is null then
    raise exception 'farm name is required';
  end if;

  if nullif(trim(p_location), '') is null then
    raise exception 'farm location is required';
  end if;

  insert into public.farms (id, farm_id, name, location, notes, created_by)
  values (
    v_farm_id,
    v_farm_id,
    trim(p_name),
    trim(p_location),
    nullif(trim(coalesce(p_notes, '')), ''),
    v_user
  );

  insert into public.farm_members (id, farm_id, user_id, role)
  values (gen_random_uuid(), v_farm_id, v_user, 'owner');

  perform public.bump_sync_server_version(v_farm_id::text);

  return v_farm_id;
end;
$$;

revoke all on function public.create_farm(text, text, text) from public;
grant execute on function public.create_farm(text, text, text) to authenticated;
