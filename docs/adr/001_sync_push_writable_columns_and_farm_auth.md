# ADR-001: sync_push enforces writable_columns allow-list and authorises against stored farm_id

Status: Accepted
Date: 2026-10-15

## Context

The original `sync_push` implementation derived `v_farm_id` from the client payload and accepted any column the client chose to include in the JSON body. This meant a malicious client could (a) overwrite another farm's row by sending that row's `id` with its own `farm_id`, and (b) set server-owned columns such as `server_version`, `created_by`, or `deleted_group_id` directly. The `writable_columns` array in `sync_table_config` was populated but never read by the function, so the config had no effect.

## Decision

`sync_push` now enforces a two-layer defence for every upsert. First, the incoming payload is filtered to the `writable_columns` list from `sync_table_config` before any data reaches the database — unknown or server-owned keys are silently dropped. Second, for any existing row, the stored `farm_id` is loaded from the database before the upsert and authorisation is checked against that stored value, not the client-supplied one. `farm_id` is excluded from every `DO UPDATE SET` clause so it can never change after insert. The generic upsert path is built dynamically from `writable_columns`, so adding a new synced table requires only a `sync_table_config` row — no function edits.

## Consequences

- Security hardened: cross-farm IDOR write path is closed; server-owned columns cannot be overwritten by clients.
- The function is slightly more complex due to the dynamic SQL for the generic upsert path.
- Config-driven design means onboarding a new table is a single `INSERT INTO sync_table_config` — no function migration required.
- Reference tables (`kind = 'reference'`) are rejected with a non-retryable `forbidden` error rather than silently skipped.
