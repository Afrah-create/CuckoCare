# ADR-006: Vet discovery returns only privacy-preserving data

Status: Accepted
Date: 2026-10-15

## Context

`list_available_vets(p_farm_id)` returned raw vet coordinates (`latitude`, `longitude`) to every caller and accepted any `farm_id` without checking that the caller was a member of that farm. This allowed a farmer to enumerate vet locations by probing with arbitrary farm IDs, and it exposed precise vet location data to all authenticated users regardless of consent. The function also returned vets regardless of verification status or whether they had opted in to the discovery feature, and had no result limit.

## Decision

`list_available_vets` now requires the caller to be a member of the supplied `p_farm_id`, verified via `is_farm_member`. The response includes `distance_km` (computed from the vet's location to the farm) and `district` only — raw `latitude` and `longitude` are excluded. Results are filtered to vets where `is_verified = true`, `is_active = true`, and `opted_in = true`. A `p_limit` parameter (default 50, maximum 100) caps the result set. The function is revoked from `public` and `anon` and granted only to `authenticated`.

## Consequences

- Privacy preserved: farmers learn how far away a vet is and which district they serve, but not their exact coordinates.
- Farmers see less geographic detail than before; this is the intended tradeoff.
- Vet proximity remains useful for farmer decision-making.
- The `is_verified`, `is_active`, and `opted_in` columns added to `vet_profiles` default to `false`/`true` — existing vets will not appear in results until an administrator sets `is_verified = true` (see open questions in `docs/feed-module-review.md`).
