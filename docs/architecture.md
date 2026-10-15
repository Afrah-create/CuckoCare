# CukoCare Architecture

CukoCare is an offline-first Android Flutter application for poultry farmers.
Drift is the on-device source of truth. Supabase is the sync target, backup, and RPC host.
The device works fully without a connection; changes are queued and reconciled transparently.

---

## Layers

```
Widgets  ──►  Riverpod providers  ──►  Use-cases / Repositories  ──►  Drift (local)
                                                                         │
                                                                   SyncEngine
                                                                         │
                                                                   Supabase (remote)
```

- **Widgets** never import Drift, Supabase, or HTTP packages. All data access goes through Riverpod providers.
- **Repositories** read and write only Drift. Writes to synced tables also insert an outbox row in the same transaction (`writeSynced`).
- **Domain** code is pure Dart — no Flutter, Drift, or Supabase imports.
- **IDs** are client-generated UUID v7. The server never generates IDs.
- **Dates** are stored (never ages). Batch age is computed at read time from `acquired_on` and `age_at_acquisition_days`.

---

## Sync Protocol

CukoCare uses a custom push/pull sync protocol built on Supabase Postgres functions.
The protocol is designed for multi-device, offline-first operation with per-farm data isolation.

### Per-scope counters

Each farm has a monotonically increasing `server_version` counter. Every row in a synced table carries `server_version` set by a Postgres trigger on insert or update. The client tracks the highest `server_version` it has seen per scope (farm). `sync_pull` streams rows whose `server_version` is greater than the client's known value, in ascending order, so the client can checkpoint incrementally.

### sync_push contract

Clients push an ordered array of operations (upserts and soft-deletes). Each operation carries an `op_id` (UUID), a `table` name, an `op` type (`upsert` or `delete`), and a `payload` (JSON object with column values).

The function enforces the following invariants on every operation:

1. **Allow-list enforcement** — the payload is filtered to the `writable_columns` array from `sync_table_config` before any data is written. Server-owned columns (`server_version`, `created_by`, `updated_at`, `deleted_group_id`) cannot be set by clients, even if included in the payload. Tables with `kind = 'reference'` are rejected with a non-retryable `forbidden` — clients never write reference data.

2. **Stored-farm authorisation** — `v_farm_id` is derived from the authenticated session and `can_farm_push(farm_id)` is called to verify membership. For an existing row, the stored `farm_id` is loaded from the database and authorisation is checked against *that* value, not the client payload. This closes the cross-farm IDOR path. `farm_id` is immutable after insert — it is excluded from every `DO UPDATE SET` clause.

3. **Terminal-only idempotency** — `sync_ops_applied` stores only terminal outcomes: a successful apply or a non-retryable rejection. Transient failures (FK violations, `retryable = true`) are returned to the client but not stored, so the client can retry after the dependency is satisfied. See [ADR-002](adr/002_terminal_only_idempotency_records.md).

4. **Duplicate preservation** — replaying an already-applied `op_id` returns the original result with a `duplicate: true` flag added. The `status` field is not overwritten.

5. **Per-operation isolation** — each operation in a batch runs in its own sub-transaction. A failed operation does not roll back successful ones in the same call.

6. **Safe error codes** — `sqlerrm` is never returned to the client. Only stable error code strings (`forbidden`, `not_found`, `fk_violation`) are exposed.

7. **Numeric server_version** — the `server_version` field in the response is always a `bigint`, not a string.

For the full security rationale see [ADR-001](adr/001_sync_push_writable_columns_and_farm_auth.md).

### sync_pull streaming model

`sync_pull(p_farm_id, p_scope_version)` returns all rows for the farm where `server_version > p_scope_version`, ordered by `server_version` ascending. The client applies rows in order, advancing its stored `server_version` after each successful batch. Soft-deleted rows (where `deleted_at is not null`) are included so tombstones propagate.

### SyncApply conflict resolution rules

The `SyncApply` Dart class applies rows received from `sync_pull` to the local Drift database:

- **Mutable tables** (`kind = 'mutable'` in `sync_table_config`): incoming rows are upserted. If the local row has a newer `updated_at` than the incoming row and the local row is not yet in the outbox, the incoming row wins (last-writer-wins by `server_version`).
- **Append-only tables** (`kind = 'append_only'`): rows are only inserted, never updated. A duplicate `id` is ignored.
- **Reference tables** (`kind = 'reference'`): rows are upserted unconditionally — the client never writes these, so there is no conflict.
- **Soft deletes**: a row with `deleted_at is not null` causes the local row to be soft-deleted in Drift. The local copy is not hard-deleted so foreign-key references from local-only rows remain intact.
- **Feed-specific**: `feed_items` and `feed_transactions` are handled by dedicated mappers in `_mapperFor`. Feed stock is never stored; it is recomputed from transactions by `FeedMetrics.compute` at read time (see [ADR-004](adr/004_feed_stock_derived_in_feed_metrics.md)).

### Table configuration

Each synced table is described by a row in `sync_table_config`:

| Column | Purpose |
|--------|---------|
| `table_name` | Postgres table name |
| `kind` | `mutable`, `append_only`, or `reference` |
| `writable_columns` | Array of column names clients may write |

Adding a new synced table requires only a new `sync_table_config` row. No `sync_push` function edits are required unless the table needs a special handler (e.g., task monotonicity, vet request state machine).

---

## Feed Module

Feed stock is **derived**, never stored. `FeedMetrics.compute` is the sole computation point.

```
FeedItem + [FeedTransaction] ──► FeedMetrics.compute ──► FeedMetrics
                                                             ├── currentQuantity  (clamped ≥ 0)
                                                             ├── rawQuantity      (may be negative)
                                                             ├── isInconsistent   (rawQuantity < 0)
                                                             ├── totalPurchased / Consumed / Wasted
                                                             ├── totalAdjustment  (signed)
                                                             └── totalCost
```

Transaction kinds: `purchase` (stock in), `consumption` (stock out by birds), `wastage` (stock out by spoilage), `adjustment` (signed correction — positive = stock in, negative = stock out). See [ADR-003](adr/003_canonical_feed_transaction_kinds.md).

---

## Vet Discovery

`list_available_vets` returns only `distance_km` and `district` — never raw coordinates. Requires farm membership. Filters to `is_verified`, `is_active`, and `opted_in` vets. See [ADR-006](adr/006_vet_discovery_privacy_preserving.md).

---

## ADR Index

| ADR | Title |
|-----|-------|
| [ADR-001](adr/001_sync_push_writable_columns_and_farm_auth.md) | sync_push enforces writable_columns allow-list and authorises against stored farm_id |
| [ADR-002](adr/002_terminal_only_idempotency_records.md) | Only terminal outcomes are stored in sync_ops_applied |
| [ADR-003](adr/003_canonical_feed_transaction_kinds.md) | Canonical feed transaction kinds and signed adjustment semantics |
| [ADR-004](adr/004_feed_stock_derived_in_feed_metrics.md) | Feed stock is derived exclusively in FeedMetrics.compute |
| [ADR-005](adr/005_server_controlled_vet_request_transitions.md) | Server-controlled vet request state transitions; pending_sync removed as a server status |
| [ADR-006](adr/006_vet_discovery_privacy_preserving.md) | Vet discovery returns only privacy-preserving data |
| [ADR-007](adr/007_migration_hygiene.md) | Migration hygiene — one concern per file, no edits to applied migrations |
