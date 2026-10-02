-- RBAC: farmer vs veterinary professional at account creation (immutable role).
-- NOTE: role helper functions MUST exist before policies that reference them.

-- ---------------------------------------------------------------------------
-- profiles.app_role
-- ---------------------------------------------------------------------------

alter table public.profiles
  add column if not exists app_role text not null default 'farmer';

alter table public.profiles drop constraint if exists profiles_app_role_check;
alter table public.profiles add constraint profiles_app_role_check
  check (app_role in ('farmer', 'vet'));

create or replace function public.profiles_lock_app_role()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'UPDATE' and old.app_role is distinct from new.app_role then
    raise exception 'app_role cannot be changed after registration'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_lock_app_role on public.profiles;
create trigger profiles_lock_app_role
  before update on public.profiles
  for each row execute function public.profiles_lock_app_role();

-- ---------------------------------------------------------------------------
-- Role helpers (before any policy references them)
-- ---------------------------------------------------------------------------

create or replace function public.current_app_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select p.app_role from public.profiles p where p.user_id = (select auth.uid())),
    'farmer'
  );
$$;

create or replace function public.is_vet()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.current_app_role() = 'vet';
$$;

create or replace function public.is_farmer()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.current_app_role() = 'farmer';
$$;

revoke all on function public.current_app_role() from public;
grant execute on function public.current_app_role() to authenticated;

revoke all on function public.is_vet() from public;
grant execute on function public.is_vet() to authenticated;

revoke all on function public.is_farmer() from public;
grant execute on function public.is_farmer() to authenticated;

-- ---------------------------------------------------------------------------
-- Vet profile stub
-- ---------------------------------------------------------------------------

create table if not exists public.vet_profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  organization text,
  offers_consultation boolean not null default true,
  offers_farm_visit boolean not null default true,
  poultry_specialist boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.vet_profiles enable row level security;

drop policy if exists vet_profiles_select_own on public.vet_profiles;
create policy vet_profiles_select_own on public.vet_profiles
  for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists vet_profiles_insert_own on public.vet_profiles;
create policy vet_profiles_insert_own on public.vet_profiles
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and public.current_app_role() = 'vet'
  );

drop policy if exists vet_profiles_update_own on public.vet_profiles;
create policy vet_profiles_update_own on public.vet_profiles
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Sign-up trigger
-- ---------------------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_role text := coalesce(new.raw_user_meta_data->>'app_role', 'farmer');
  v_name text := coalesce(
    new.raw_user_meta_data->>'display_name',
    nullif(split_part(coalesce(new.email, ''), '@', 1), '')
  );
begin
  if v_role not in ('farmer', 'vet') then
    v_role := 'farmer';
  end if;

  insert into public.profiles (user_id, display_name, phone, app_role)
  values (new.id, v_name, new.phone, v_role)
  on conflict (user_id) do nothing;

  if v_role = 'vet' then
    insert into public.vet_profiles (user_id, display_name)
    values (new.id, v_name)
    on conflict (user_id) do nothing;
  end if;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Farmers only: create_farm
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

  if public.current_app_role() <> 'farmer' then
    raise exception 'only farmers can create farms' using errcode = '42501';
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
