# ADR 011: Sync RPCs use SECURITY DEFINER

## Status

Accepted

## Context

`offline.md` specifies `SECURITY INVOKER` for `sync_push` while also revoking direct `INSERT/UPDATE/DELETE` on synced tables for `authenticated`. In PostgreSQL, invoker functions cannot write to tables the role cannot write to.

## Decision

Implement `sync_push`, `sync_pull`, `sync_head`, and `sync_bootstrap` as **SECURITY DEFINER** with explicit membership/role checks inside the function body, mirroring RLS intent.

## Consequences

- pgTAP must assert authorization inside RPCs, not only RLS on tables.
- Table grants remain read-only for authenticated direct access.
