# ADR 002: Custom outbox sync vs PowerSync

## Status

Accepted (scaffold)

## Context

We need delta sync with explicit conflict rules and a path to swap implementations later.

## Decision

Implement `SyncEngine` + outbox table + Supabase `sync_push` / `sync_pull` RPCs behind interfaces. Defer PowerSync until product validation.

## Consequences

- More SQL and client sync code to maintain initially.
- Clear ownership of conflict policy and table coverage.
