# ADR 006: Per-scope commit-ordered sync counters

## Status

Accepted

## Context

A global `server_version` sequence assigns values in call order, not commit order, so cursor-based pull can skip rows permanently.

## Decision

Use `sync_counters(scope)` with row-level locking via upsert in `BEFORE INSERT OR UPDATE` triggers. Clients keep **one cursor per scope** (farm id or `reference`), not per table.

## Consequences

- Pull returns a single ordered stream per scope (UNION ALL across configured tables).
- Migrations replace `global_server_version_seq` from `0001` in `0002`.
