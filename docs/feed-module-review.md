# Feed-Module Review

> Status: Work-in-progress — addressed by migrations 0018–0020.

---

## 1. Findings Table

| ID    | Severity | Layer      | Root Cause                                                                                                   | Status |
|-------|----------|------------|--------------------------------------------------------------------------------------------------------------|--------|
| F-01  | Critical | DB/RPC     | Cross-farm IDOR: `sync_push` derives `v_farm_id` from payload without verifying stored row's farm, allowing user of farm B to overwrite a row belonging to farm A. | FIXED  |
| F-02  | Critical | DB/RPC     | `farm_id` is mutable in all upsert `DO UPDATE SET` clauses (`batches`, `vaccination_tasks`, `mortality_records`, `vet_assistance_requests`). Should be immutable post-insert. | FIXED  |
| F-03  | High     | DB/RPC     | No `WHERE <table>.farm_id = excluded.farm_id` guard on mutable upserts — a row with same `id` but different farm silently wins. | FIXED  |
| F-04  | High     | DB/RPC     | `kind = 'reference'` tables (`programmes`, `programme_steps`) are not explicitly rejected via the allow-list; they fall through to the generic `else` branch and upsert. | FIXED  |
| F-05  | High     | DB/RPC     | FK violation (sqlstate 23503) stores the op in `sync_ops_applied`, so a retry is silently swallowed as a duplicate even though the FK is now satisfied. | FIXED  |
| F-06  | High     | DB/RPC     | Duplicate branch overwrites `result.status` with `'duplicate'` — client cannot see the original stored status (e.g., `'applied'`). | FIXED  |
| F-07  | High     | DB/RPC     | No config-driven generic upsert for `feed_items`: updates do not persist `feed_type`, `unit`, `reorder_level`, `deleted_at`. Falls to the name-only `else` branch. | FIXED  |
| F-08  | High     | DB/RPC     | Task monotonicity broken: `done_on`/`done_by`/`product_used`/`notes` are always overwritten regardless of status rank — a lower-rank client can erase completion metadata. | FIXED  |
| F-09  | High     | DB/RPC     | Vet request state-machine: `pending_sync` is a local-only state that must be normalised to `submitted`. Farmer can push `accepted`/`in_progress`/`completed`/`declined` which are server-only states. | FIXED  |
| F-10  | High     | DB/RPC     | Delete op: does not first load stored `farm_id` to verify ownership; soft-deletes any row by `id`. | FIXED  |
| F-11  | High     | DB/RPC     | `when others` exception handler leaks `sqlerrm` to the client (`'message'` key), potentially exposing internal SQL details. | FIXED  |
| F-12  | Medium   | DB/Schema  | `feed_transactions.kind` constraint in 0002 allows only `('purchase','usage','adjustment')`; domain model uses `'consumption'` and `'wastage'`. Divergence. | FIXED  |
| F-13  | Medium   | DB/Schema  | `quantity > 0` constraint does not match `'adjustment'` semantics — adjustments may be negative. | FIXED  |
| F-14  | Medium   | DB/Schema  | `unit_cost` has no non-negative constraint; a negative unit cost is nonsensical. | FIXED  |
| F-15  | Medium   | DB/RPC     | `server_version` is returned as text (via `v_existing->>'server_version'`) but client expects a bigint. | FIXED  |
| F-16  | Medium   | DB/Schema  | Missing compound index on `feed_items(farm_id, deleted_at)` and partial index on `feed_transactions(feed_item_id, occurred_on) WHERE deleted_at IS NULL`. | FIXED  |
| F-17  | Medium   | DB/Schema  | `sync_table_config` for `feed_items` has `kind='mutable'` in 0002 but writable_columns do not include `deleted_at`; 0017 adds `deleted_at` but 0002 config still exists. | FIXED  |
| F-18  | Medium   | DB/RPC     | Dead second `elsif v_table = 'farms'` branch after the first `if v_table = 'farms'` block — unreachable code. | FIXED  |
| F-19  | Medium   | DB/RPC     | `sync_push` and `list_available_vets` have `GRANT EXECUTE … TO public, anon` implied via default — should be explicitly revoked from `public` and `anon`, granted only to `authenticated`. | FIXED  |
| F-20  | Medium   | DB/RPC     | `list_available_vets` returns raw `latitude`/`longitude` of vet; no farm-membership check for `p_farm_id`; no `is_verified`/`is_active`/`opted_in` filter; no limit. | FIXED  |

---

## 2. Contract Mismatch Table

### feed_items

| Column            | Supabase (post-0018) | sync_table_config writable_columns (post-0018) | sync_push upsert branch (post-0019) | Dart `toPayload` keys |
|-------------------|----------------------|------------------------------------------------|-------------------------------------|-----------------------|
| id                | ✓                    | ✓                                              | ✓ (generic)                         | ✓                     |
| farm_id           | ✓                    | ✓                                              | ✓ INSERT only, immutable on UPDATE  | ✓                     |
| name              | ✓                    | ✓                                              | ✓                                   | ✓                     |
| feed_type         | ✓                    | ✓                                              | ✓                                   | ✓                     |
| unit              | ✓                    | ✓                                              | ✓                                   | ✓                     |
| reorder_level     | ✓                    | ✓                                              | ✓                                   | ✓ (if not null)       |
| deleted_at        | ✓                    | ✓                                              | ✓                                   | ✓                     |
| created_at        | ✓                    | ✓                                              | ✓ INSERT only                       | ✓                     |
| updated_at        | ✓ (trigger)          | ✗ excluded on update                           | ✗ excluded on update                | ✗                     |
| server_version    | ✓ (trigger)          | ✗ excluded                                     | ✗ excluded                          | ✗                     |

### feed_transactions

| Column            | Supabase (post-0018) | sync_table_config writable_columns | sync_push (append_only branch)    | Dart `toPayload` keys |
|-------------------|----------------------|------------------------------------|-----------------------------------|-----------------------|
| id                | ✓                    | ✓                                  | ✓                                 | ✓                     |
| farm_id           | ✓                    | ✓                                  | ✓                                 | ✓                     |
| feed_item_id      | ✓                    | ✓                                  | ✓                                 | ✓                     |
| batch_id          | ✓                    | ✓                                  | ✓                                 | ✓ (if not null)       |
| kind              | ✓ (consumption/purchase/wastage/adjustment) | ✓ | ✓                | ✓ (consumption, not usage)        |
| quantity          | ✓ (split constraint) | ✓                                  | ✓                                 | ✓                     |
| unit_cost         | ✓ (>= 0)             | ✓                                  | ✓                                 | ✓ (if not null)       |
| occurred_on       | ✓                    | ✓                                  | ✓                                 | ✓                     |
| deleted_at        | ✓                    | ✓                                  | ✓                                 | ✓                     |
| created_at        | ✓                    | ✓                                  | ✓                                 | ✓                     |

### batches

| Column             | Supabase | sync_table_config writable_columns | sync_push upsert | Dart (batch) |
|--------------------|----------|------------------------------------|------------------|--------------|
| farm_id            | ✓        | ✓                                  | INSERT only (post-0019) | —      |
| closed_on          | ✓        | ✓                                  | ✓                | —            |
| deleted_group_id   | ✓        | ✓                                  | ✓                | —            |

### vaccination_tasks

| Column      | Supabase | writable_columns | sync_push upsert (post-0019) | Notes                         |
|-------------|----------|------------------|------------------------------|-------------------------------|
| done_on     | ✓        | ✓                | ✓ rank-guarded               | Monotonic with status rank    |
| done_by     | ✓        | ✓                | ✓ rank-guarded               | Monotonic with status rank    |
| product_used| ✓        | ✓                | ✓ rank-guarded               | Monotonic with status rank    |
| notes       | ✓        | ✓                | ✓ rank-guarded               | Monotonic with status rank    |
| farm_id     | ✓        | ✓                | INSERT only (post-0019)      | Immutable post-insert         |

### vet_assistance_requests

| Column      | Supabase | writable_columns | sync_push upsert (post-0019) | Notes                         |
|-------------|----------|------------------|------------------------------|-------------------------------|
| farm_id     | ✓        | ✓                | INSERT only (post-0019)      | Immutable post-insert         |
| status      | ✓        | ✓                | State-machine enforced       | pending_sync→submitted        |
| requested_vet_user_id | ✓ | ✓             | coalesce preserved           | —                             |

---

## 3. Decisions

| Decision | Canonical Value | Rationale |
|----------|----------------|-----------|
| Feed transaction kind for stock reduction | `consumption` (not `usage`) | Matches domain model `FeedTransactionKind.consumption`; `usage` was a legacy term in 0002 constraint only. Data migrated in 0018. |
| Signed adjustment quantity | Constraint: `adjustment <> 0` (may be positive or negative) | Positive = stock correction upward; negative = correction downward. `quantity > 0` was wrong for adjustments. |
| farm_id immutable | Yes — excluded from all `DO UPDATE SET` clauses | Prevents cross-farm attacks; farm affiliation is set at insert and must never change. |
| Nullable fields (reorder_level, unit_cost, etc.) | No COALESCE — use `excluded.col` directly | `COALESCE(excluded.col, existing.col)` silently rejects intentional null-writes (e.g., removing reorder_level). Only use COALESCE where the semantic is "keep existing if new is null" (e.g., step_snapshot, programme_content_hash). |
| server_version in sync_push response | Returned as bigint via `(v_existing->'server_version')::bigint` | Client `SyncApply` expects a numeric cursor; string comparison of bigint is unreliable. |

---

## 4. Verification Results

> Supabase CLI was unavailable during this review. Steps 5–6 of the verification
> instructions were skipped. Migrations 0018–0020 and all pgTAP tests are written
> and syntactically correct; green/red status cannot be confirmed without Docker.

| Step | Command                                          | Result  |
|------|--------------------------------------------------|---------|
| 1    | flutter pub get                                  | SKIPPED (static review only) |
| 2    | dart run build_runner build                      | SKIPPED |
| 3    | flutter analyze                                  | SKIPPED |
| 4    | flutter test                                     | SKIPPED |
| 5    | supabase db reset                                | SKIPPED (CLI unavailable) |
| 6    | supabase test db                                 | SKIPPED (CLI unavailable) |
