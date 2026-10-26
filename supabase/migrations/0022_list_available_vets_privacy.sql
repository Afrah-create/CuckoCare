-- 0022: Harden list_available_vets and stop farmers reading vet_profiles.
--
-- Why: 0021 still omitted farmer-role checks, coalesced phone, rounded
-- distance, and search_path hardening. 0012 also let any farmer SELECT
-- vet_profiles (phone + coordinates). 0021 backfilled is_verified for all
-- active opted-in rows; this file does not repeat that.
--
-- Rollback: restore list_available_vets from 0021; recreate
-- vet_profiles_select_farmer; drop admin_set_vet_verified and the
-- verification-protect trigger.

drop policy if exists vet_profiles_select_farmer on public.vet_profiles;

create or replace function public.vet_profiles_protect_verification()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE'
     and new.is_verified is distinct from old.is_verified
     and pg_catalog.current_setting('role', true) is distinct from 'service_role'
     and current_user is distinct from 'postgres' then
    new.is_verified := old.is_verified;
  end if;
  return new;
end;
$$;

drop trigger if exists vet_profiles_protect_verification on public.vet_profiles;
create trigger vet_profiles_protect_verification
  before update on public.vet_profiles
  for each row
  execute function public.vet_profiles_protect_verification();

create or replace function public.admin_set_vet_verified(
  p_user_id uuid,
  p_verified boolean
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if pg_catalog.current_setting('role', true) is distinct from 'service_role'
     and current_user is distinct from 'postgres' then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  update public.vet_profiles
  set is_verified = p_verified, updated_at = pg_catalog.now()
  where user_id = p_user_id;
end;
$$;

revoke execute on function public.admin_set_vet_verified(uuid, boolean) from public, anon, authenticated;
grant execute on function public.admin_set_vet_verified(uuid, boolean) to service_role;

create or replace function public.list_available_vets(
  p_farm_id uuid default null,
  p_limit int default 50
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_limit int := pg_catalog.least(pg_catalog.greatest(pg_catalog.coalesce(p_limit, 50), 1), 100);
  v_lat double precision;
  v_lon double precision;
  v_vets jsonb;
begin
  if auth.uid() is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;

  if public.current_app_role() is distinct from 'farmer' then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_farm_id is not null then
    if not public.is_farm_member(
      p_farm_id,
      array['owner', 'manager', 'worker', 'viewer']
    ) then
      raise exception 'forbidden' using errcode = '42501';
    end if;
    select f.latitude, f.longitude
      into v_lat, v_lon
    from public.farms f
    where f.id = p_farm_id and f.deleted_at is null;
  end if;

  select pg_catalog.coalesce(
    pg_catalog.jsonb_agg(r.entry order by r.km nulls last, r.name),
    '[]'::jsonb
  )
  into v_vets
  from (
    select
      pg_catalog.jsonb_build_object(
        'user_id', v.user_id,
        'display_name', pg_catalog.coalesce(v.display_name, p.display_name, 'Veterinarian'),
        'organization', v.organization,
        'district', v.district,
        'offers_consultation', v.offers_consultation,
        'offers_farm_visit', v.offers_farm_visit,
        'phone', pg_catalog.coalesce(v.phone, p.phone),
        'distance_km', pg_catalog.round(d.km::numeric, 1)
      ) as entry,
      d.km,
      pg_catalog.coalesce(v.display_name, p.display_name, 'Veterinarian') as name
    from public.vet_profiles v
    join public.profiles p on p.user_id = v.user_id and p.app_role = 'vet'
    cross join lateral (
      select case
        when v_lat is not null and v_lon is not null
         and v.latitude is not null and v.longitude is not null
        then 6371 * pg_catalog.acos(pg_catalog.least(1.0, pg_catalog.greatest(-1.0,
               pg_catalog.cos(pg_catalog.radians(v_lat)) * pg_catalog.cos(pg_catalog.radians(v.latitude))
               * pg_catalog.cos(pg_catalog.radians(v.longitude) - pg_catalog.radians(v_lon))
               + pg_catalog.sin(pg_catalog.radians(v_lat)) * pg_catalog.sin(pg_catalog.radians(v.latitude)))))
      end as km
    ) d
    where v.is_verified and v.is_active and v.opted_in
    order by d.km nulls last, pg_catalog.coalesce(v.display_name, p.display_name, 'Veterinarian')
    limit v_limit
  ) r;

  return pg_catalog.jsonb_build_object('vets', v_vets);
end;
$$;

revoke execute on function public.list_available_vets(uuid, integer) from public, anon;
grant execute on function public.list_available_vets(uuid, integer) to authenticated;
