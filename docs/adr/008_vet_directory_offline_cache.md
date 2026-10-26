# ADR-008: Offline cache for the vet directory

Status: Accepted
Date: 2026-10-18

## Context

Find a Vet is a live RPC (`list_available_vets`). Farmers often work with poor connectivity. A failed RPC previously showed a generic error even when a list had loaded earlier in the session.

A dedicated Drift table would duplicate a privacy-sensitive directory that is not farm-owned sync data.

## Decision

Cache the last successful directory payload per farm in `SharedPreferences` for seven days. When offline or when a live fetch fails, show the cached list with `StaleDataCaption`. Demo sessions never call the RPC.

## Consequences

- Farmers can still contact previously listed vets while offline.
- Cached rows may include a vet who later opted out until the TTL expires or a refresh succeeds.
- No new Drift table or sync contract for directory data.
