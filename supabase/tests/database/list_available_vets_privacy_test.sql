-- Extra privacy checks for migration 0022.
begin;
select plan(4);

select ok(
  not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'vet_profiles'
      and policyname = 'vet_profiles_select_farmer'
  ),
  'farmers must not have a blanket select policy on vet_profiles'
);

select ok(
  (
    select prosecdef from pg_proc
    join pg_namespace ns on ns.oid = pg_proc.pronamespace
    where ns.nspname = 'public' and proname = 'list_available_vets'
    limit 1
  ),
  'list_available_vets remains security definer'
);

select ok(
  (
    select prosecdef from pg_proc
    join pg_namespace ns on ns.oid = pg_proc.pronamespace
    where ns.nspname = 'public' and proname = 'admin_set_vet_verified'
    limit 1
  ),
  'admin_set_vet_verified exists and is security definer'
);

select ok(
  not has_function_privilege(
    'authenticated',
    'public.admin_set_vet_verified(uuid, boolean)',
    'execute'
  ),
  'authenticated cannot execute admin_set_vet_verified'
);

select * from finish();
rollback;
