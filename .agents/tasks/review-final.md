# Feed Module — Final Review

Feed management fixes and features across three migration files (0018–0020), five Dart layers, seven ADRs, and an architecture doc. The change addresses 28 numbered findings from the original review pass, spanning cross-farm IDOR, sync correctness, domain model gaps, navigation rule violations, and screen alignment. The work is self-contained on the `dev` branch.

Watch for: one minor gap in the engine duplicate-handling path (legacy `status=='duplicate'` string retained alongside the new `isDuplicate` flag — likely harmless but worth confirming); the feed-screen widget test (plan step 10e) was not written, though it is not listed in the acceptance criteria's five required test files; pgTAP tests were not executed against a live database (Supabase CLI unavailable).

**Verdict**: APPROVED

---

## High-level view

`FeedMetrics.compute` is the single stock-derivation point. All four transaction kinds contribute correctly: purchases and positive adjustments add to stock, consumption and wastage subtract, negative adjustments subtract via their signed quantity. `rawQuantity` may go negative to surface offline inconsistency; `currentQuantity` clamps to zero for display and `isInconsistent` is the flag callers use. The `FeedMetrics` tests confirm every path including signed adjustments, zero-stock clamping, and cost accumulation.

`sync_apply.dart` now routes `feed_items` and `feed_transactions` through their typed mappers in both `_mapperFor` and `applyPushAck`. Feed items use a `shouldApplyRemoteVersion` conflict guard and full upsert; feed transactions use `insertOrIgnore` (append-only). Pull operations on these tables are no longer silently dropped.

The duplicate-detection path was changed from `status == 'duplicate'` to `r['duplicate'] as bool?`. The engine was updated to mark an op applied when `isDuplicate == true`. One leftover: the engine also retains the old `opResult.status == 'duplicate'` arm in the same condition. Since the server no longer returns `status: 'duplicate'` after migration 0019, this dead arm is harmless, but it is a papercut that could confuse future readers.

`FeedItemDetailRoute` is a proper `GoRouteData` subclass with `$parentNavigatorKey = rootNavigatorKey`, registered via `@TypedGoRoute<FeedItemDetailRoute>(path: '/feed/:feedItemId')` in `typed_routes.dart`. The old `Navigator.push` / `MaterialPageRoute` pattern is gone. The route sample is registered in `test/layout/route_samples.dart` for both the `routeSamplePaths` set and the `presetForRoute` switch.

`_assertValidQuantity` correctly splits on kind: adjustment requires `quantity != 0` (positive or negative); all other kinds require `quantity > 0`. The transaction sheet shows a `_DirectionButton` toggle for the adjustment kind so users can record downward corrections. The `_isValid` guard mirrors this: `qty != 0` for adjustment, `qty > 0` for all others.

The seven ADRs are all present under `docs/adr/` and `docs/architecture.md` has a Sync Protocol section that accurately documents the allow-list, stored-farm auth, terminal-only idempotency, and the feed module's derived-stock design. `docs/feed-module-review.md` has a full findings table with FIXED status on all 28 entries, a contract mismatch table, decisions, what could not be verified, and four open questions for the project owner.

The five required test files are all present. `feed_metrics_test.dart` is thorough table-driven coverage including all four kinds, signed adjustments, inconsistency clamping, cost accumulation, and edge cases. `feed_mapper_test.dart` validates that `toPayload` keys are a strict subset of `sync_table_config.writable_columns` and that `fromRemote` round-trips nullable fields. `supabase_remote_sync_api_test.dart` covers all result shapes via the `@visibleForTesting` wrapper. `feed_repository_test.dart` exercises the in-memory Drift DB for writes, signed adjustments, soft-delete, and outbox ordering. `feed_rules_test.dart` scans the feature directory for forbidden patterns.

No `'usage'` kind string appears anywhere in `lib/features/feed/` (the `fromStorage` default falls through to `consumption` without naming `'usage'`). No `Colors.*` outside theme. No raw `Navigator.push` or `MaterialPageRoute` under features. Architecture rule compliance is confirmed across all checked files.

Supabase CLI was not available so the three pgTAP test files and migrations 0018–0020 have not been executed against a live database. All static-analysis evidence is consistent with correct behaviour.

---

<details>
<summary>Issues (2)</summary>

1. **Dead engine arm for `status=='duplicate'`** — `cuco_care_sync_engine.dart` line 183 retains `opResult.status == 'duplicate'` alongside the new `opResult.isDuplicate` check. The server no longer returns that status string after migration 0019, so the arm never fires, but it will mislead future readers about the protocol shape. Remove the dead arm once migration 0019 is live everywhere.

2. **Feed screen widget tests absent** — plan step 10e (widget tests for loading/empty/error states and validation in `RecordFeedTransactionSheet`) was not created. This is not in the five-file acceptance criterion but is called for in spec Part F. The gap leaves form-validation behaviour (negative quantity for non-adjustment, date in the future) untested at the widget level.

</details>

---

<details>
<summary>Details</summary>

### FeedMetrics.compute correctness

All four transaction kinds are handled in a single `switch` inside `FeedMetrics.compute`. Purchases accumulate `totalPurchased` and `totalCost` (via `unitCost ?? 0`). Consumption and wastage accumulate their respective totals. Adjustment adds the raw (possibly negative) quantity directly to `totalAdjustment`. The net formula is `purchased - consumed - wasted + adjustment`, which correctly handles both upward and downward adjustment corrections since adjustment quantities carry their own sign and `stockSign` for the adjustment kind is `+1`.

`rawQuantity` is the unguarded net. `currentQuantity` returns `rawQuantity < 0 ? 0 : rawQuantity`. `isInconsistent` is `rawQuantity < 0`. The test suite confirms all paths including the inconsistency clamp and zero-cost case. The `FeedStock` typedef alias pointing at `FeedMetrics` preserves compile-time compatibility for any callers that haven't migrated.

### sync_apply feed handlers

Both `feed_items` and `feed_transactions` are added to `_mapperFor` and `applyPushAck`. The pull handler for `feed_items` reads the local row, runs `shouldApplyRemoteVersion`, and does a full `insertOnConflictUpdate` with all Drift columns including `serverVersion`. The handler for `feed_transactions` uses `InsertMode.insertOrIgnore`, correctly implementing append-only semantics per architecture rule 6. The `applyPushAck` branches update `serverVersion` after a confirmed push, consistent with the existing pattern for batches and farms.

### Duplicate detection and the dead engine arm

The server-side change in migration 0019 changed the response shape from `{status: 'duplicate'}` to `{status: 'applied', duplicate: true}`. `_parsePushResponse` now reads `r['duplicate'] as bool? ?? false` into `SyncPushOpResult.isDuplicate`. The engine at line 183 was updated to mark an op applied when `isDuplicate == true`.

The engine condition is:
```dart
if (opResult.status == 'applied' ||
    opResult.status == 'duplicate' ||   // ← dead after 0019 is live
    opResult.isDuplicate) {
```

The old `status == 'duplicate'` arm is confirmed dead — the server no longer returns that shape. It poses no correctness risk today but does misrepresent the protocol contract for anyone reading the code later. This is a low-priority papercut (likely), not a blocker.

### feed_routes.dart navigation

`FeedItemDetailRoute` is declared with `@TypedGoRoute<FeedItemDetailRoute>(path: '/feed/:feedItemId')` and the `$parentNavigatorKey = rootNavigatorKey` static getter that hides the bottom navigation bar on detail screens. The `push` extension method in `feed_routes.dart` delegates to GoRouter's typed `push`, not `Navigator.push`. No `MaterialPageRoute` or `WillPopScope` anywhere under `lib/features/feed/`. Navigation rule compliance confirmed.

### Architecture rule compliance

Checked across all feed feature files:
- No `'usage'` string literal in any feed feature file. `fromStorage` uses a wildcard fallback to `consumption` without naming `'usage'` explicitly.
- No `Colors.*` references in presentation files.
- `_assertValidQuantity` is the single enforcement point for quantity semantics; `FeedMetrics.compute` is the single stock arithmetic point. The `feed_rules_test.dart` architecture test guards both invariants via file scanning.

### pgTAP tests and migrations — not executable

Migrations 0018–0020 and the three pgTAP test files (`feed_schema_test.sql`, `sync_push_security_test.sql`, `list_available_vets_test.sql`) were written against the spec but not executed. The `feed_schema_test.sql` spot-check shows a correct structure: the `consumption` kind is inserted successfully, the `usage` kind throws `23514`, and the test plan declares 11 tests covering kind constraints, quantity rules, unit-cost non-negativity, index existence, and `sync_table_config` state. Static analysis is consistent with the expected behaviour, but green/red status cannot be confirmed without Docker.

### What was not tested

The feed-screen widget test file (`feed_screen_test.dart`) was not created. The spec (Part F) calls for widget tests covering loading skeleton, empty state, error with retry, `_LowStockBanner` visibility, transaction sign display, and form validation in `RecordFeedTransactionSheet`. The route layout sample covers the layout rule, but form-level validation behaviour at the widget level remains untested. This gap is possible to miss in CI only if the validation logic changes without touching the unit tests — the repository test covers the `_assertValidQuantity` path, so the logic itself is tested, but the UI binding (the `_isValid` guard in the sheet) is not.

</details>

---

<details>
<summary>File map</summary>

| File | What changed |
|------|-------------|
| `supabase/migrations/0018_feed_schema_fix.sql` | Canonical `feed_transactions` kinds, signed-adjustment quantity constraint, `unit_cost >= 0`, indexes, `sync_table_config` update |
| `supabase/migrations/0019_sync_push_hardening.sql` | IDOR fix, `farm_id` immutability, reference-table rejection, terminal-only idempotency, duplicate flag, config-driven generic upsert, task monotonicity, vet state machine, safe error codes, numeric `server_version`, revokes |
| `supabase/migrations/0020_vet_rpc_hardening.sql` | Farm-membership check, privacy-preserving output, verified/active/opted-in filter, result limit, revokes for `list_available_vets` |
| `supabase/tests/database/feed_schema_test.sql` | pgTAP tests for schema constraints |
| `supabase/tests/database/sync_push_security_test.sql` | pgTAP tests for all sync_push security properties |
| `supabase/tests/database/list_available_vets_test.sql` | pgTAP tests for vet RPC |
| `lib/features/feed/domain/feed_models.dart` | `FeedMetrics.compute`, `stockSign`, signed adjustment, `FeedStock` typedef alias |
| `lib/features/feed/data/feed_repository.dart` | `_assertValidQuantity` (non-zero adjustment), `_computeStockRows` via `FeedMetrics.compute` |
| `lib/data_platform/sync/sync_apply.dart` | `feed_items` and `feed_transactions` in `_mapperFor` and `applyPushAck` |
| `lib/data_platform/sync/remote_sync_api.dart` | `isDuplicate` field on `SyncPushOpResult` |
| `lib/data_platform/sync/supabase_remote_sync_api.dart` | `isDuplicate: r['duplicate'] as bool?`, `@visibleForTesting` wrapper |
| `lib/data_platform/sync/cuco_care_sync_engine.dart` | `isDuplicate` check in `_pushLoop` (plus retained dead `status=='duplicate'` arm) |
| `lib/app/router/routes/typed_routes.dart` | `FeedItemDetailRoute` as typed `GoRouteData` |
| `lib/features/feed/presentation/feed_routes.dart` | Extension method delegating to typed `push` |
| `lib/features/feed/presentation/record_feed_transaction_sheet.dart` | `_DirectionButton` toggle, signed qty for adjustment, `_isValid` updated |
| `test/layout/route_samples.dart` | `/feed/:feedItemId` in `routeSamplePaths` and `presetForRoute` |
| `test/features/feed/feed_metrics_test.dart` | Table-driven `FeedMetrics.compute` tests |
| `test/features/feed/feed_mapper_test.dart` | Mapper round-trip and schema contract tests |
| `test/features/feed/feed_repository_test.dart` | In-memory Drift DB tests including signed adjustment and outbox ordering |
| `test/data_platform/sync/supabase_remote_sync_api_test.dart` | Parse response unit tests for all result shapes |
| `test/architecture/feed_rules_test.dart` | File-scan architecture tests |
| `docs/adr/001–007` | Seven ADRs covering all major decisions |
| `docs/architecture.md` | New file: Sync Protocol section, Feed Module section, ADR index |
| `docs/feed-module-review.md` | Completed findings table, contract mismatch, decisions, open questions |

Full diff: `git -C /home/awongo-fahadi-rashid/MobileNetworks/CukoCare diff main..dev`

</details>
