-- 0020: Vet RPC hardening
--
-- Addresses: F-20 (list_available_vets: no raw coordinates, farm-membership check,
-- verified/active/opted-in filter, result limit, anon rejection).
-- Also adds is_verified / is_active / opted_in columns to vet_profiles.
--
-- One concern: vet_profiles schema + list_available_vets function replacement.

-- ---------------------------------------------------------------------------
-- 1. Add is_verified, is_active, opted_in columns to vet_profiles
-- ---------------------------------------------------------------------------

alter table public.vet_profiles
  add column if not exists is_verified boolean not null default false,
  add column if not exists is_active   boolean not null default true,
  add column if not exists opted_in    boolean not null default true;

-- ---------------------------------------------------------------------------
-- 2. Revoke before replacing to close any privilege window
-- ---------------------------------------------------------------------------

revoke execute on function public.list_available_vets(uuid) from public;
revoke execute on function public.list_available_vets(uuid) from anon;

-- ---------------------------------------------------------------------------
-- 3. Replace list_available_vets with hardened version
-- ---------------------------------------------------------------------------

create or replace function public.list_available_vets(
  p_farm_id uuid default null,
  p_limit   int  default 50
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit     int := least(greatest(coalesce(p_limit, 50), 1), 100);
  v_farm_lat  double precision;
  v_farm_lon  double precision;
  v_rows      jsonb;
begin
  -- ── Auth ────────────────────────────────────────────────────────────────────
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  -- ── Farm membership check ───────────────────────────────────────────────────
  if p_farm_id is not null then
    if not public.is_farm_member(p_farm_id) then
      raise exception 'forbidden' using errcode = '42501';
    end if;

    -- Fetch GPS for distance sort (only if member, so already verified above).
    select f.latitude, f.longitude
      into v_farm_lat, v_farm_lon
    from public.farms f
    where f.id = p_farm_id and f.deleted_at is null;
  end if;

  -- ── Build result (no latitude/longitude in output) ──────────────────────────
  select coalesce(
    jsonb_agg(entry order by (entry->>'distance_km')::double precision nulls last),
    '[]'::jsonb
  )
  into v_rows
  from (
    select jsonb_build_object(
      'user_id',             v.user_id,
      'display_name',        coalesce(v.display_name, p.display_name, 'Veterinarian'),
      'organization',        v.organization,
      'district',            v.district,
      'offers_consultation', v.offers_consultation,
      'offers_farm_visit',   v.offers_farm_visit,
      -- Deliberately omit latitude and longitude from response.
      'distance_km', case
        when v_farm_lat is not null and v_farm_lon is not null
          and v.latitude is not null and v.longitude is not null
        then (
          6371 * acos(
            least(1.0, greatest(-1.0,
              cos(radians(v_farm_lat)) * cos(radians(v.latitude))
              * cos(radians(v.longitude) - radians(v_farm_lon))
              + sin(radians(v_farm_lat)) * sin(radians(v.latitude))
            ))
          )
        )
        else null
      end
    ) as entry
    from public.vet_profiles v
    join public.profiles p on p.user_id = v.user_id and p.app_role = 'vet'
    where v.is_verified = true
      and v.is_active   = true
      and v.opted_in    = true
    order by (
      case
        when v_farm_lat is not null and v_farm_lon is not null
          and v.latitude is not null and v.longitude is not null
        then (
          6371 * acos(
            least(1.0, greatest(-1.0,
              cos(radians(v_farm_lat)) * cos(radians(v.latitude))
              * cos(radians(v.longitude) - radians(v_farm_lon))
              + sin(radians(v_farm_lat)) * sin(radians(v.latitude))
            ))
          )
        )
        else null
      end
    ) nulls last
    limit v_limit
  ) ranked;

  return jsonb_build_object('vets', v_rows);
end;
$$;

-- Grant to authenticated only.
revoke execute on function public.list_available_vets(uuid, integer) from public;
revoke execute on function public.list_available_vets(uuid, integer) from anon;
grant  execute on function public.list_available_vets(uuid, integer) to authenticated;
