# ADR 005: Session caching policy

## Status

Accepted

## Context

Users must open the app and work offline even when access tokens expire.

## Decision

Persist Supabase session encrypted; maintain `AuthSnapshot` in Drift; never sign out on network failure; re-sign-in only when refresh is rejected online or user chooses sign-out. Different user sign-in requires explicit confirmation before wiping local data.

## Consequences

- `SessionGate` and router logic must not call network on cold start.
- `offlineGraceDays` gates sync/premium verification, not local records.
