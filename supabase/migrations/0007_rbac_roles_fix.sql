-- Run this if 0007 failed partway (policies before functions).
-- Safe to run on a DB that already applied the corrected 0007.

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

grant execute on function public.current_app_role() to authenticated;
grant execute on function public.is_vet() to authenticated;
grant execute on function public.is_farmer() to authenticated;

drop policy if exists vet_profiles_insert_own on public.vet_profiles;
create policy vet_profiles_insert_own on public.vet_profiles
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and public.current_app_role() = 'vet'
  );
