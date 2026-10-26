# Vet directory

Farmers discover verified veterinary officers through **Find a Vet** (`/more/vets`). Vets never appear as farm members.

## What farmers can see

The RPC `list_available_vets(p_farm_id, p_limit)` returns a JSON object `{ "vets": [ ... ] }` with:

- display name, organisation, district
- services (`offers_consultation`, `offers_farm_visit`)
- phone (`coalesce(vet_profiles.phone, profiles.phone)`)
- `distance_km` rounded to 0.1 km when both the farm and the vet have coordinates

Farmers **cannot** read `vet_profiles` directly (no blanket select policy). Coordinates are never returned.

Callers must be authenticated farmers and, when `p_farm_id` is set, members of that farm. Unsynced local farms fall back to a null farm id (no distances) in the client.

## Verification

`vet_profiles.is_verified` defaults to false. Authenticated vets cannot change it (trigger copies the previous value). To verify locally or in staging:

```sql
select public.admin_set_vet_verified('VET_USER_UUID', true);
```

That function is granted to `service_role` (and the local `postgres` role). There is no admin UI in this pass.

Migration `0021` backfilled `is_verified = true` for rows that were already active and opted in. New vets after that still need verification.

## Vet portal

Vets edit name, organisation, district, phone, services, availability, and opt-in on **Your profile** (`/vet/more/profile`). Location uses the same GPS capture card as before. The screen shows **Pending verification** or **Visible to farmers**.

## Offline

The last successful list is cached per farm for 7 days (`SharedPreferences`). Offline Find a Vet shows that list with a stale caption.

## Seed data (dev / staging)

`supabase/seed_dev_vets.sql` (appended by `tool/generate_seed.dart`) inserts clearly fake vets near Kampala, Wakiso, and Mbale, plus one unverified row that must not appear in the directory. Do not use these emails or numbers in production.
