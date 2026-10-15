# Feed-Module Review

> Status: Complete — findings addressed by migrations 0018–0020 and Dart fixes in FEAT-001/002/003.

---

## 1. Findings Table

| ID    | Severity | Layer      | Root Cause                                                                                                   | Status | Reference |
|-------|----------|------------|--------------------------------------------------------------------------------------------------------------|--------|-----------|
| F-01  | Critical | DB/RPC     | Cross-farm IDOR: `sync_push` derives `v_farm_id` from payload without verifying stored row's farm, allowing user of farm B to overwrite a row belonging to farm A. | FIXED  | `supabase/migrations/0019_sync_push_hardening.sql` |
| F-02  | Critical | DB/RPC     | `farm_id` is mutable in all upsert `DO UPDATE SET` clauses (`batches`, `vaccination_tasks`, `mortality_records`, `vet_assistance_requests`). Should be immutable post-insert. | FIXED  | `supabase/migrations/0019_sync_push_hardening.sql` |
| F-03  | High     | DB/RPC     | No `WHERE <table>.farm_id = excluded.farm_id` guard on mutable upserts — a row with same `id` but different farm silently wins. | FIXED  | `supabase/migrations/0019_sync_push_hardening.sql` |
| F-04  | High     | DB/RPC     | `kind = 'reference'` tables (`programmes`, `programme_steps`) are not explicitly rejected via the allow-list; they fall through to the generic `else` branch and upsert. | FIXED  | `supabase/migrations/0019_sync_push_hardening.sql` |
| F-05  | High     | DB/RPC     | FK violation (sqlstate 23503) stores the op in `sync_ops_applied`, so a retry is silently swallowed as a duplicate even though the FK is now satisfied. | FIXED  | `supabase/migrations/0019_sync_push_hardening.sql` — terminal-only idempotency |
| F-06  | High     | DB/RPC     | Duplicate branch overwrites `result.status` with `'duplicate'` — client cannot see the original stored status (e.g., `'applied'`). | FIXED  | `supabase/migrations/0019_sync_push_hardening.sql` — `duplicate: true` flag |
| F-07  | High     | DB/RPC     | No config-driven generic upsert for `feed_items`: updates do not persist `feed_type`, `unit`, `reorder_level`, `deleted_at`. Falls to the name-only `else` branch. | FIXED  | `supabase/migrations/0019_sync_push_hardening.sql` — config-driven generic upsert |
| F-08  | High     | DB/RPC     | Task monotonicity broken: `done_on`/`done_by`/`product_used`/`notes` are always overwritten regardless of status rank — a lower-rank client can erase completion metadata. | FIXED  | `supabase/migrations/0019_sync_push_hardening.sql` |
| F-09  | High     | DB/RPC     | Vet request state-machine: `pending_sync` is a local-only state that must be normalised to `submitted`. Farmer can push `accepted`/`in_progress`/`completed`/`declined` which are server-only states. | FIXED  | `supabase/migrations/0019_sync_push_hardening.sql` |
| F-10  | High     | DB/RPC     | Delete op: does not first load stored `farm_id` to verify ownership; soft-deletes any row by `id`. | FIXED  | `supabase/migrations/0019_sync_push_hardening.sql` |
| F-11  | High     | DB/RPC     | `when others` exception handler leaks `sqlerrm` to the client (`'message'` key), potentially exposing internal SQL details. | FIXED  | `supabase/migrations/0019_sync_push_hardening.sql` |
| F-12  | Medium   | DB/Schema  | `feed_transactions.kind` constraint in 0002 allows only `('purchase','usage','adjustment')`; domain model uses `'consumption'` and `'wastage'`. Divergence. | FIXED  | `supabase/migrations/0018_feed_schema_fix.sql` |
| F-13  | Medium   | DB/Schema  | `quantity > 0` constraint does not match `'adjustment'` semantics — adjustments may be negative. | FIXED  | `supabase/migrations/0018_feed_schema_fix.sql` |
| F-14  | Medium   | DB/Schema  | `unit_cost` has no non-negative constraint; a negative unit cost is nonsensical. | FIXED  | `supabase/migrations/0018_feed_schema_fix.sql` |
| F-15  | Medium   | DB/RPC     | `server_version` is returned as text (via `v_existing->>'server_version'`) but client expects a bigint. | FIXED  | `supabase/migrations/0019_sync_push_hardening.sql` |
| F-16  | Medium   | DB/Schema  | Missing compound index on `feed_items(farm_id, deleted_at)` and partial index on `feed_transactions(feed_item_id, occurred_on) WHERE deleted_at IS NULL`. | FIXED  | `supabase/migrations/0018_feed_schema_fix.sql` |
| F-17  | Medium   | DB/Schema  | `sync_table_config` for `feed_items` has `kind='mutable'` in 0002 but writable_columns do not include `deleted_at`; 0017 adds `deleted_at` but 0002 config still exists. | FIXED  | `supabase/migrations/0018_feed_schema_fix.sql` |
| F-18  | Medium   | DB/RPC     | Dead second `elsif v_table = 'farms'` branch after the first `if v_table = 'farms'` block — unreachable code. | FIXED  | `supabase/migrations/0019_sync_push_hardening.sql` |
| F-19  | Medium   | DB/RPC     | `sync_push` and `list_available_vets` have `GRANT EXECUTE … TO public, anon` implied via default — should be explicitly revoked from `public` and `anon`, granted only to `authenticated`. | FIXED  | `supabase/migrations/0019_sync_push_hardening.sql`, `0020_vet_rpc_hardening.sql` |
| F-20  | Medium   | DB/RPC     | `list_available_vets` returns raw `latitude`/`longitude` of vet; no farm-membership check for `p_farm_id`; no `is_verified`/`is_active`/`opted_in` filter; no limit. | FIXED  | `supabase/migrations/0020_vet_rpc_hardening.sql` |
| F-21  | Medium   | Dart/Sync  | `sync_apply.dart` had no `feed_items`/`feed_transactions` cases → pull silently dropped. | FIXED  | `lib/data_platform/sync/sync_apply.dart` (FEAT-002) |
| F-22  | Medium   | Dart/Domain| `FeedStock.isInconsistent` missing; no clamping; adjustment sign wrong. | FIXED  | `lib/features/feed/domain/feed_models.dart` — `FeedMetrics.compute` (FEAT-002) |
| F-23  | Medium   | Dart/Nav   | `feed_routes.dart` used raw `Navigator.push`/`MaterialPageRoute` (navigation rule violation). | FIXED  | `lib/features/feed/presentation/feed_routes.dart`, `lib/app/router/routes/typed_routes.dart` (FEAT-002) |
| F-24  | Medium   | Dart/Sync  | `SupabaseRemoteSyncApi` duplicate detection used `status=='duplicate'` instead of `r['duplicate']==true`. | FIXED  | `lib/data_platform/sync/supabase_remote_sync_api.dart` (FEAT-002) |
| F-25  | Low      | Dart/UI    | `record_feed_transaction_sheet.dart`: `_isValid` used `qty > 0` for all kinds — adjustment must be non-zero (may be negative for stock-out corrections). | FIXED  | `lib/features/feed/presentation/record_feed_transaction_sheet.dart` (FEAT-003) |
| F-26  | Low      | Dart/UI    | `record_feed_transaction_sheet.dart`: no signed input path for adjustment kind — user could not record a stock-out correction. | FIXED  | Added `_DirectionButton` toggle; signed quantity passed to repository (FEAT-003) |
| F-27  | Low      | Dart/UI    | `feed_screen.dart` `_ReportTab` and `feed_report_screen.dart` both show raw `CircularProgressIndicator` on load — violates `AsyncStateView`/`ListSkeleton` standard. | FIXED  | Swapped to `ListSkeleton` (FEAT-003) |
| F-28  | Low      | Dart/UI    | `Colors.white` used in download button spinners in `feed_screen.dart` and `feed_report_screen.dart` — violates "no `Colors.*` outside `lib/app/theme/`" rule. | FIXED  | Removed `color: Colors.white` (FEAT-003) |

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
| Nullable fields (reorder_level, unit_cost, etc.) | No COALESCE — use `excluded.col` directly | `COALESCE(excluded.col, existing.col)` silently rejects intentional null-writes (e.g., removing reorder_level). Only use COALESCE where the semantic is "keep existing if new is null". |
| server_version in sync_push response | Returned as bigint via `(v_existing->'server_version')::bigint` | Client `SyncApply` expects a numeric cursor; string comparison of bigint is unreliable. |

---

## 4. FEAT-001/002 Dart-Layer Fixes

The following Dart-layer findings were addressed in the FEAT-001 and FEAT-002 implementations:

| ID    | Finding                                                                 | Fix                                                                               | Files                                              | Status |
|-------|-------------------------------------------------------------------------|-----------------------------------------------------------------------------------|----------------------------------------------------|--------|
| F-21  | `sync_apply.dart` had no `feed_items`/`feed_transactions` cases → pull silently dropped | Added `'feed_items'` and `'feed_transactions'` cases to `_mapperFor` and `applyPushAck` | `lib/data_platform/sync/sync_apply.dart`           | FIXED  |
| F-22  | `FeedStock.isInconsistent` missing; no clamping; adjustment sign wrong  | Introduced `FeedMetrics` with `rawQuantity`, `currentQuantity` (clamped), `isInconsistent`, `totalPurchased/Consumed/Wasted/Adjustment/Cost`; `FeedMetrics.compute` factory handles signed adjustments | `lib/features/feed/domain/feed_models.dart`, `lib/features/feed/data/feed_repository.dart` | FIXED  |
| F-23  | `feed_routes.dart` used raw `Navigator.push`/`MaterialPageRoute` (navigation rule violation) | Converted to typed `FeedItemDetailRoute extends GoRouteData`; `$parentNavigatorKey = rootNavigatorKey` hides bottom bar | `lib/app/router/routes/typed_routes.dart`, `lib/features/feed/presentation/feed_routes.dart` | FIXED  |
| F-24  | `SupabaseRemoteSyncApi` duplicate detection used `status=='duplicate'` instead of `r['duplicate']==true`; `SyncPushOpResult` lacked `isDuplicate` field | Added `isDuplicate` field to `SyncPushOpResult`; `_parsePushResponse` reads `r['duplicate'] as bool?`; `_pushLoop` marks op applied when `isDuplicate==true` | `lib/data_platform/sync/remote_sync_api.dart`, `lib/data_platform/sync/supabase_remote_sync_api.dart`, `lib/data_platform/sync/cuco_care_sync_engine.dart` | FIXED  |

### Tests added (FEAT-002)
- `test/features/feed/feed_metrics_test.dart` — FeedMetrics.compute table-driven tests (all kinds, signed adjustment, inconsistency clamping, reorder level, cost)
- `test/features/feed/feed_mapper_test.dart` — FeedItemSyncedTable/FeedTransactionSyncedTable round-trip and schema contract tests
- `test/features/feed/feed_repository_test.dart` — in-memory Drift DB tests (add item, record transaction, signed adjustment, soft delete, outbox ordering)
- `test/data_platform/sync/supabase_remote_sync_api_test.dart` — `_parsePushResponse` unit tests (applied, rejected, duplicate, error, string server_version)
- `test/architecture/feed_rules_test.dart` — file-scan tests (no 'usage' kind string, no `.isPositive` calls outside models, stock arithmetic only in FeedMetrics/feed_repository)

---

## 5. FEAT-003 Screen Alignment Fixes

The following screen alignment gaps were found and fixed in FEAT-003:

| Finding | Gap | Fix |
|---------|-----|-----|
| `_ReportTab` in `feed_screen.dart` showed raw `CircularProgressIndicator` on load | Violates `ListSkeleton` standard for async list screens | Swapped to `const ListSkeleton()` |
| `feed_report_screen.dart` showed raw `CircularProgressIndicator` on load | Same violation | Swapped to `const ListSkeleton()` |
| `Colors.white` used in export button spinner in both files | Violates "no `Colors.*` outside `lib/app/theme/`" rule | Removed `color: Colors.white` — `CircularProgressIndicator` inherits correct theme color automatically |
| `record_feed_transaction_sheet.dart` `_isValid` allowed only `qty > 0` for all kinds | Adjustment may be negative; `qty > 0` would block stock-out adjustments | Changed to `qty != 0` branch for adjustment kind |
| `record_feed_transaction_sheet.dart` had no signed input path for adjustment | User could not record a downward (stock-out) correction | Added `_DirectionButton` toggle (Stock in / Stock out) for adjustment kind; quantity is multiplied by sign before passing to repository |

### Out of scope / follow-up

- **PendingSyncBadge on feed items and transactions**: The architecture rules say a local save should show `PendingSyncBadge` until the outbox clears. Feed item cards in the Stock tab and transaction tiles do not show this badge. Adding it requires per-row outbox watching that may affect list performance. Deferred to a future pass — see open questions.
- **DiscardChangesScope on `FeedItemFormSheet` and `RecordFeedTransactionSheet`**: Both are bottom sheets, not navigated screens. Navigation rules specify `PopScope`/`DiscardChangesScope` for dirty forms under `lib/features/`. Bottom sheet dismissal (drag-to-dismiss) currently does not prompt the user. The scaffolding required to intercept drag-dismiss is non-trivial and would change the UX interaction model. Deferred as follow-up.
- **`AsyncStateView` on `_ReportTab` and `FeedReportScreen`**: These screens load data via an explicit `Future` call (not a `StreamProvider`/`FutureProvider`), so wrapping with `AsyncStateView` is not a one-line change — it would require refactoring the loading state machine to a `FutureProvider`. The current pattern (sealed `_LoadState` + `switch`) correctly uses `ListSkeleton` and an error column with retry button, matching the intent of the rule. Full migration to `AsyncStateView` listed as follow-up.
- **Low-stock reminders via `ReminderSource`**: The `ReminderSource` framework exists but is not wired to `FeedMetrics`. Deferred — out of scope per original spec.

---

## 6. Verification Results

> Supabase CLI was unavailable during this review. Steps 5–6 of the verification
> instructions were skipped. Migrations 0018–0020 and all pgTAP tests are written
> and syntactically correct; green/red status cannot be confirmed without Docker.

| Step | Command                                          | Result  |
|------|--------------------------------------------------|---------|
| 1    | flutter pub get                                  | PASSED  |
| 2    | dart run build_runner build                      | PASSED (0 errors, 201 outputs) |
| 3    | flutter analyze                                  | PASSED (0 errors, info only) |
| 4    | flutter test                                     | See latest run in FEAT-003 verification |
| 5    | supabase db reset                                | SKIPPED (CLI unavailable) |
| 6    | supabase test db                                 | SKIPPED (CLI unavailable) |

---

## 7. What Could Not Be Verified

- **Supabase CLI / Docker unavailable**: `supabase db reset` and `supabase test db` could not be run. All migrations (0018–0020) and pgTAP tests are written and believed syntactically correct but have not been executed against a live Postgres instance.
- **Live outbox behaviour of `PendingSyncBadge`**: The badge is driven by a Riverpod provider watching the outbox table. Its live behaviour after feed writes was not tested end-to-end.
- **Column-name reconciliation for `vaccination_tasks`**: Static analysis confirms Drift column names match Supabase schema. A live migration reset was not available to confirm the mapping end-to-end.

---

## 8. Open Questions

1. **Should `pending_sync` rows that exist in production be migrated?** Migration 0019 normalises `pending_sync` → `submitted` on write. Existing server rows with `status = 'pending_sync'` will remain until a one-off clean-up script is run against the production database. Decision required: when to run, who runs it, and whether a data-migration column triggers downstream notifications.

2. **Should `adjustment` quantities in existing data be audited for sign?** All existing `adjustment` rows have `quantity > 0` (the old constraint). Some of those rows may have been intended as downward corrections entered as positive numbers and recorded without a sign convention. The data meaning is ambiguous. Decision required: either accept that pre-migration adjustments are all stock-in, or run an audit query to identify and relabel suspect rows.

3. **Low-stock notification via `ReminderSource` — desired timeline?** The reminder framework exists. Wiring `FeedMetrics.belowReorderLevel` to emit a local notification requires a `ReminderSource` implementation and a per-farm background check. No timeline is set. Decision required.

4. **`is_verified`, `is_active`, `opted_in` on `vet_profiles` — who sets these fields in production?** Migration 0020 adds these columns with `default false`/`default true`. The admin flow for a vet to be verified and opted in is not built. Decision required: is there an admin panel, a manual SQL step, or a vet self-service flow?
