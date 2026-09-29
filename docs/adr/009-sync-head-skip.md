# ADR 009: Single stream per scope with sync_head skip

## Status

Accepted

## Decision

`sync_pull(scope, since, limit)` returns one version-ordered stream across all tables in the scope. Clients call `sync_head` first and skip pull when head equals the local cursor.

## Consequences

- Lower mobile data use on quiet farms.
- Hydration progress is measured in pulled rows, not per-table passes.
