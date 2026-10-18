# CucoCare: review and fix the pushed feed-module migration, and align it with the project (prompt for Kiro)

Paste everything below the line into Kiro at the root of the CucoCare repo. If you use Kiro's spec workflow, create the spec under `.kiro/specs/feed-module-review-fix/` (requirements, design, tasks) from this prompt and work through the tasks in order. Otherwise follow the steps below directly.

---

## Role and goal

You are a senior engineer with deep Postgres, Supabase (RLS, `SECURITY DEFINER` functions, RPC), Flutter/Drift, and offline-first sync experience. Another developer pushed a **feed-management migration** (the file is named after the feed module, but it also **redefines the whole `sync_push` function** and **adds a `list_available_vets` function**). The feed screens are already in place and **some tests fail**.

Your job: **review the migration and the feed module end to end, find and fix the real errors, and align everything with how CucoCare is built.** Fix root causes. Do not weaken, skip, or delete tests to get green. Make minimal, well-tested changes. Keep what works.

Start by reading, in this order: `docs/architecture.md`, all ADRs in `docs/adr/`, the project rules (`.cursor/rules/*.mdc` — treat them as the binding project rules; if Kiro steering files exist under `.kiro/steering/`, read those too), `docs/batch-creation-and-schedule.md`, `docs/batch-management.md` (if present), `docs/offline-sync` or the sync section of `docs/architecture.md`, every file in `supabase/migrations/` **in order** (especially earlier definitions of `sync_push`, `sync_pull`, `sync_table_config`, `sync_ops_applied`, `sync_counters`, `can_farm_push`, `is_farm_member`, `current_app_role`, `sync_epoch`, `task_status_rank`, RLS policies, triggers), `supabase/tests/` (pgTAP), `lib/data_platform/db/` (Drift tables and the schema export), `lib/data_platform/sync/`, and everything under `lib/features/feed/` plus where feed data is used (batches, Today, vet context, notifications).

## What CucoCare is, and the rules this work must respect

An offline-first Android Flutter app for poultry farmers (Drift is the source of truth, Supabase is the sync target and backup). Binding rules:

- All synced writes go through the local **outbox** (`writeSynced`), pushed through **`sync_push`** and pulled through **`sync_pull`**, with **per-scope, commit-ordered `server_version` counters**. Direct client writes to synced tables are revoked.
- **`sync_table_config`** drives sync: each table has a `kind` (`mutable`, `append_only`, `reference`) and a `writable_columns` allow-list. **Clients may only write allow-listed columns.** The server owns `server_version`, `updated_at`, ownership, and `farm_id` of existing rows. **Reference tables are never client-writable.**
- `sync_push` must be **idempotent**, **isolated per operation** (one bad op never rolls back the rest), classify errors as **retryable or not**, and **never let a client touch another farm's data**.
- **Derived values are never stored.** Feed stock is **derived** from feed transactions (like live bird count is derived in `BatchMetrics`). There must be one place (`FeedMetrics` or equivalent) that computes stock, and every consumer uses it.
- Roles: `owner`, `manager`, `worker`, `viewer` (viewer is read-only; workers may add records but not change core batch details). Vets are **not** farm members and access data only through consented, purpose-built paths.
- Workflow status of vet requests is **server-controlled**. Local sync state (for example "pending sync") is **not** a server status.
- UI follows the existing design system and rules (theme tokens, `AppPage`, shared state components, localised strings, drafts, typed routes). Do not rework screens that work.

## Ground rules

- **Do not edit a migration that may already be applied elsewhere.** Add new, numbered corrective migrations (split by concern, see Part E). If the pushed migration is provably unapplied and unmerged, you may note that squashing is possible later, but still prefer corrective migrations.
- Work only against the **local** Supabase (`supabase start`, `supabase db reset`). Never touch a remote project. If Docker or the Supabase CLI is unavailable in your environment, say so, do the static review, write the tests and migrations anyway, and list exactly what could not be run.
- No new dependencies without asking. Every fix gets a test that fails before and passes after.
- Findings below are **hypotheses from reading one file**. Verify each against the real schema, earlier migrations, Drift tables, and by running tests. Report any you could not confirm.

## Part A: Reproduce and triage (before changing anything)

1. Run: `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze`, `flutter test`, `supabase db reset`, `supabase test db`. Capture all failures.
2. Group failures by **root cause** (not by test name). For each: the failing tests, the cause, and which layer is wrong (migration, Drift schema, mapper, domain, UI, or the test itself). Put the table in `docs/feed-module-review.md`.
3. Build the **contract mismatch table**: for `feed_items`, `feed_transactions`, `batches`, `vaccination_tasks`, `mortality_records`, `farms`, `vet_assistance_requests`: compare the columns in **(a)** the Supabase tables, **(b)** `sync_table_config.writable_columns`, **(c)** the columns the new `sync_push` upserts, **(d)** the Drift tables, and **(e)** the Dart payload mappers (`toPayload`/`fromRemote`). List every name, type, and enum difference. Pay particular attention to: `usage` versus `consumption` (and `wastage`) transaction kinds; `occurrence`/`enabled`/`done_by`/`shifted_from`/`production_type`/`programme_content_hash` (in the migration) versus the names in our docs and Drift (`occurrence_index`, `is_enabled`, `completion_source`, `original_due_on`, `shift_days`, `schedule_choice`, `bird_type`, `programme_version`). **Decide the canonical names from the app's source of truth (Drift plus the docs, unless the app code has already adopted the other developer's names)** and fix the mismatch at the lowest-cost layer, with a data-preserving migration or mapper change. Record each decision.

## Part B: Review checklist for the migration (verify each; fix what is real)

### B1. Security (highest priority, treat as blocking)

1. **Cross-farm write (IDOR) in `sync_push`.** `v_farm_id` is taken from the **client payload** (`coalesce(payload.farm_id, row_id)`), and the upserts use `on conflict (id) do update set farm_id = excluded.farm_id, ...`. A client can send its own farm id with **another farm's row id** and pass the membership check, then overwrite or move the victim's row. Only the `mortality_records` branch has `where table.farm_id = excluded.farm_id`. Fix: for any existing row, **load the stored `farm_id` and authorise against it**; make `farm_id` immutable (remove it from every `do update set`); add the `where ... farm_id = excluded.farm_id` guard (or compare to the stored value) to **every** upsert; reject on mismatch.
2. **Delete ops are not farm-checked.** The `delete` path does `update ... set deleted_at = now() where id = $1` with `v_farm_id` derived from a payload that delete ops may not even carry (so it can fail for legitimate deletes and succeed for foreign ones). Fix: derive the farm from the stored row, authorise, and return `not_found` (non-retryable) when the row does not exist.
3. **`writable_columns` is never enforced.** `jsonb_populate_record(null::table, payload)` accepts **any** key (`created_by`, `deleted_group_id`, server-owned columns). The migration edits `writable_columns`, but the function ignores it, so those edits have no effect. Fix: **filter the payload to the allow-list** before use (and reject unknown or forbidden keys), and build upserts from the allow-list instead of hand-written column lists.
4. **Reference tables are writable.** The code skips the authorisation check for `programmes`/`programme_steps` and then runs the generic upsert. Fix: **reject any op on a `reference`-kind table** with a non-retryable `forbidden`.
5. **Vet request state machine.** The `vet_assistance_requests` branch only checks that the **incoming** status is in `('draft','pending_sync','submitted','cancelled')`, then upserts `status = excluded.status`. A farmer can **revert** a vet-controlled state (accepted, in progress, completed) back to `submitted` or `cancelled`. Also `pending_sync` is a local sync state, not a workflow status. Fix: enforce **allowed transitions server-side** (farmer may create as draft/submitted, may cancel only before the vet accepts, may not regress), remove `pending_sync` from server statuses (migrate any such rows), and add the `farm_id` guard.
6. **`list_available_vets(p_farm_id)` discloses data.** It reads the coordinates of **any farm id** supplied without checking the caller belongs to that farm, so a farmer can probe other farms' locations through the distances. It also returns **vets' exact coordinates** to every farmer, includes vets regardless of verification or availability (despite the name), and has no limit. Fix: require **farm membership**; return **distance and district only** (or rounded coordinates, never raw), only for **verified, active, opted-in** vets, with a result limit; use `is_farm_member`.
7. **Information leak:** `sync_push` returns `sqlerrm` to the client. Return only a stable error code.
8. **Grants:** the functions are `grant ... to authenticated` but are not revoked from `PUBLIC`/`anon`. Add `revoke execute ... from public, anon`. Consider `set search_path = ''` with fully qualified names for the two `SECURITY DEFINER` functions (Supabase security advisor guidance), and note why they are `DEFINER` (the project's earlier design was `INVOKER` so RLS applies; if `DEFINER` is kept, every branch must authorise explicitly, and a test must prove it).
9. **Cross-tenant references in feed rows.** The feed branch inserts `feed_transactions` with any `feed_item_id` and `batch_id` the client sends. The foreign keys are satisfied by **another farm's** ids. The mortality branch checks that the batch belongs to the same farm, the feed branch does not. Fix: enforce same-farm references (composite foreign keys `(feed_item_id, farm_id)` → `feed_items(id, farm_id)` and `(batch_id, farm_id)` → `batches(id, farm_id)`, or a validated check in the apply step), for `feed_transactions` and any other table that references another table.
10. **Role checks:** vets (non-members) can currently create farms through the `farms` branch. Restrict farm creation to farmer accounts, and verify worker versus owner/manager permissions match the project rules for each table.

### B2. Data-loss and correctness bugs

1. **Retryable failures are recorded as done.** The `fk_violation` handler (`retryable: true`) **inserts the failed result into `sync_ops_applied`**. On the next retry the op hits the "already applied" branch and returns `duplicate`, so a transient parent-not-yet-synced failure becomes **permanent**. Fix: **only store terminal outcomes** (applied, or non-retryable rejection) in `sync_ops_applied`.
2. **Duplicates mask rejections.** The duplicate path does `stored_result || {'status':'duplicate'}`, overwriting a stored `rejected` status, so the client treats a rejected op as acknowledged and drops it silently. Fix: return the **original status** plus a `duplicate: true` flag.
3. **Generic upsert drops data.** For any table that is not special-cased (including **`feed_items`**), the final `else` branch only updates `name` and `updated_at`. Edits to `feed_type`, `unit`, `reorder_level`, and `deleted_at` **never sync**, and tables without a `name` column will **error at runtime** (plpgsql resolves columns at execution, so `create or replace` succeeding proves nothing). Fix: a **config-driven generic upsert** over `writable_columns` (excluding `id`, `farm_id`, `created_at` on update), with small, explicit hooks only for genuine special cases.
4. **Monotonic task status protects `status` but not the rest.** In the `vaccination_tasks` branch, when an incoming status has a lower rank, the stored status is kept but `done_on`, `done_by`, `product_used`, `notes` are still overwritten, which can erase completion data. Fix: apply the whole update only when the incoming status is accepted (or otherwise keep the winning row's fields).
5. **`coalesce(excluded.x, table.x)` prevents clearing values** (farm `latitude`, `longitude`, `phone`, and so on), so a farmer cannot remove a location or number. Use "key present in payload means set, including null; absent means keep".
6. **`farms` creation runs the insert twice** (a manual insert for new farms, then the generic upsert) and trusts payload fields such as `created_by`. Simplify to one controlled path that sets `created_by = auth.uid()`.
7. **Type and contract drift:** `server_version` is returned as text; return a number. Confirm the Dart `SupabaseRemoteSyncApi` parses the result shape (`status`, `duplicate`, `server_version`, `row`, `error_code`, `retryable`) exactly, including `retryable` handling and the oversized-payload response.
8. **Dead and hidden failures:** columns referenced in static SQL that do not exist (for example `production_type`, `programme_content_hash`) will fail only when executed. Add a test that **executes every branch** against the real schema.
9. **Feed transaction kinds.** The check now allows `purchase, consumption, wastage, adjustment, usage`. `usage` and `consumption` are the same idea, which makes stock derivation ambiguous. Choose **one canonical kind** (align with Drift and the domain enum, with `consumption` as the default if the app has not already adopted `usage`), migrate existing rows, define the sign and meaning of `adjustment` (signed quantity, non-zero), and add CHECK constraints: `quantity > 0` for purchase, consumption, and wastage; `quantity <> 0` for adjustment; `unit_cost >= 0` when present. Keep a temporary alias only if needed, with a documented removal.
10. The `feed_transactions` index is fine, but confirm there is also a `(farm_id, server_version)` index (needed by pull) and a partial index for non-deleted rows if queries filter on `deleted_at is null`.

### B3. Scope and hygiene

- The migration mixes three concerns (feed schema, a full `sync_push` rewrite, and a vet-discovery RPC). **Split into separate corrective migrations** (Part E). Compare the new `sync_push` against its **previous definition** (`git log -p`) and list anything the rewrite regressed or silently changed (per-op isolation, size limits, farm creation, role rules, epoch, idempotency).
- Verify the helper functions it calls exist in the right order and with the right signatures: `can_farm_push(uuid)`, `is_farm_member(uuid, text[])`, `current_app_role()`, `sync_epoch()`, `task_status_rank(text)`.
- Prefer refactoring `sync_push` toward the **config-driven design** (generic apply from `writable_columns`, small per-table hooks for: farm creation, task status monotonicity, vet request transitions, same-farm reference checks). If a full refactor is too large for this pass, fix in place and record a follow-up.

## Part C: Align the feed module with the app

1. **Single source of truth for stock.** Find every place stock or low-stock is computed (providers, screens, notifications, vet context, Today). Create or confirm one pure, unit-tested domain object (`FeedMetrics`/`FeedStock`) that derives: current stock per item (purchases − consumption − wastage ± adjustments, excluding soft-deleted rows), total purchased and consumed, cost totals where `unit_cost` exists, `belowReorderLevel`, days-of-stock if a consumption rate is available, and `isInconsistent` (negative derived stock after merging offline devices; clamp for display and show a calm "please review" notice, never negative numbers). Every consumer reads from it. Add an architecture test: stock is computed only there.
2. **Mutable versus append-only.** Per the project decision, **feed transactions are append-only** (new row to correct; soft-delete only to remove, with Undo) and **feed items are mutable**. Make `sync_table_config`, the Drift tables, the mappers, and the UI agree. If the UI lets users edit a transaction in place, change it to void-and-replace (or raise it as a decision if screens depend on in-place edit).
3. **Writes and roles.** Every feed write goes through `writeSynced` with correct outbox ordering (item before transactions that reference it). `viewer` is read-only; workers may record consumption and purchases (confirm against the role rules and make the server and UI agree).
4. **Batch linkage.** Consumption may reference a batch. Deleting or closing a batch must **not** delete feed transactions (they keep their value). Closed batches can still be referenced historically. Confirm and test.
5. **Screens already exist.** Do **not** redesign them. Audit them only for: reading from the shared providers, correct enum values (the kinds above), the standard states (loading skeleton, first-use empty, filtered-empty, error with retry, offline with pending badge), validation (positive quantities, date not in the future, batch belongs to the farm), drafts on forms, `AppPage`/layout presets, tokens only, localised strings, and rotation-safe behaviour. Fix gaps that are small and clearly in scope; list larger ones in the review doc.
6. **Notifications (only if the reminder framework exists).** Low-stock reminders should plug in as a `ReminderSource` using `FeedMetrics`. If that is not already done, record it as a follow-up and do not build it here.

## Part D: Fix the failing tests properly

- For each root cause from Part A, fix the cause, then confirm the related tests pass. If a test encodes behaviour that contradicts the project rules above, explain why in the review doc and update the test with a clear justification. Never delete, skip, or loosen a test just to pass.
- Add the missing tests listed in Part F.

## Part E: Deliverables (migrations)

Create separate, numbered, idempotent migrations (continue the existing numbering), each with a header comment explaining the reason and rollback notes:

1. **Feed schema fix:** canonical `kind` values and data migration (`usage` → canonical), CHECK constraints, same-farm composite references (or validated alternative), indexes, `sync_table_config` rows (`kind` and a **correct `writable_columns`** that includes every client-writable column the app really sends, and excludes server-owned ones).
2. **`sync_push` hardening:** the fixes in B1 and B2 (allow-list enforcement, stored-farm authorisation, immutable `farm_id`, reference-table rejection, terminal-only idempotency records, duplicate status preservation, config-driven generic upsert, task and request special handlers, safe error codes, numeric `server_version`, revokes).
3. **Vet RPC hardening:** `list_available_vets` membership check, privacy-preserving output, verified and active filter, limit, grants.
4. Any column-name reconciliation migrations decided in Part A.3 (data-preserving renames, never drop data).

Do not leave the old definitions as the effective ones. `supabase db reset` must succeed from scratch and the end state must be correct.

## Part F: Tests (all required)

**pgTAP (`supabase/tests/`):**
- Cross-farm: a user cannot upsert, move, soft-delete, or reference (via `feed_item_id`, `batch_id`) another farm's row; a row's `farm_id` never changes after insert.
- Payload filtering: a payload containing `server_version`, `created_by`, `deleted_group_id`, or other non-writable keys does not set them; unknown keys are ignored or rejected as designed.
- Reference tables: any `sync_push` op on `programmes`/`programme_steps` is rejected non-retryably.
- Idempotency: replaying an applied op returns `duplicate` with the original status; a **retryable FK failure is not recorded** and succeeds on retry once the parent exists; a non-retryable rejection replays as `rejected`.
- Per-op isolation: a bad op does not roll back good ones in the same call.
- Config-driven upsert: updating a `feed_items` row persists `feed_type`, `unit`, `reorder_level`, and `deleted_at`; every `writable_columns` entry for every synced table **exists as a real column** (a schema contract test) and every special-cased column list is consistent with the config.
- Feed constraints: kinds, positive and signed quantity rules, `unit_cost >= 0`, same-farm references, soft delete of a transaction through the delete op.
- Vaccination task monotonicity: a lower-rank incoming update does not erase `done_on`, `done_by`, `product_used`, or `notes`.
- Vet request transitions: allowed and forbidden farmer transitions; `pending_sync` is not an accepted server status.
- Farm fields: a location or phone can be cleared with an explicit null; omitting the key keeps the value.
- `list_available_vets`: non-member of the farm is rejected; no raw coordinates returned; unverified and inactive vets excluded; limit respected; `anon` cannot execute either function.
- Roles: viewer cannot write; worker allowed and forbidden cases match the rules.

**Dart:**
- `FeedMetrics` table-driven tests (all kinds and signs, soft-deleted rows excluded, reorder level, inconsistent merged data with clamping, zero cost, adjustments).
- Mapper contract tests: for every synced table, the keys produced by `toPayload` are a subset of the Drift columns **and** the server's `writable_columns` (derive the server list from a checked-in JSON export that a pgTAP or script step keeps in sync, or from the local database in an opt-in integration test).
- `SupabaseRemoteSyncApi` parsing of every result shape, including `duplicate`, `rejected` (retryable and not), oversized payload, and numeric `server_version`.
- Repository and engine tests with the fake remote: item then transactions ordering, undo of a soft-deleted transaction, offline create then sync, two-device concurrent purchases converge, a retryable FK rejection is retried and succeeds.
- Feed screens: widget tests for states and validation, layout matrix for the feed routes (register samples in the route registry), accessibility guidelines.
- Architecture tests: stock computed only in `FeedMetrics`; no raw `usage` kind strings outside the migration alias; no direct synced writes bypassing `writeSynced`.

## Part G: Docs

- `docs/feed-module-review.md`: findings table (ID, severity P0 security / P1 data loss or correctness / P2 alignment, evidence, fix, test, status), the failing-test triage, the contract mismatch table and decisions, what you could not verify, and open questions for me.
- Update the sync documentation (`sync_push` contract, allow-list enforcement, idempotency rules) and `docs/architecture.md`.
- ADRs: (1) `sync_push` enforces `writable_columns` and authorises against the stored farm, (2) only terminal outcomes are stored in `sync_ops_applied`, (3) canonical feed transaction kinds and `adjustment` semantics, (4) feed stock derived in `FeedMetrics`, (5) server-controlled vet request transitions and removal of `pending_sync` as a server status, (6) vet discovery returns only privacy-preserving data, (7) migration hygiene: one concern per migration, no rewriting of applied migrations.

## Acceptance criteria

1. `flutter analyze`, `flutter test`, `supabase db reset`, and `supabase test db` all pass from a clean checkout, and **no test was skipped, deleted, or weakened without a written justification**.
2. The pgTAP suite proves: no cross-farm read or write path remains; reference tables cannot be written; the allow-list is enforced; retryable failures are retried; duplicates preserve the original outcome; `feed_items` edits sync completely.
3. Every column the app sends exists server-side and is allow-listed, every allow-listed column exists, and names and enums agree across Supabase, Drift, mappers, and docs.
4. Feed stock is computed in one place and used everywhere. Offline create, sync, edit, undo, and two-device scenarios behave correctly.
5. The vet discovery function reveals nothing about farms the caller does not belong to and no exact vet coordinates.
6. The review document lists every finding with its resolution, and anything you could not verify.

## Out of scope

Redesigning feed screens, new features, low-stock notifications (unless the framework already exists), payments, vet portal changes beyond the RPC hardening, and iOS.

## Working style

Commit in small steps: (1) reproduce and triage (review doc, failing tests captured), (2) contract mismatch table and decisions, (3) pgTAP tests for the confirmed bugs (red), (4) feed schema migration, (5) `sync_push` hardening, (6) vet RPC hardening, (7) Dart mapper, API, and `FeedMetrics` fixes, (8) screen alignment fixes, (9) remaining tests, (10) docs and ADRs. After each step run the relevant suite. If something is ambiguous, choose the conservative option, record it in an ADR, and continue. If a finding needs my decision (for example the canonical transaction kind when the app already uses the other name), implement the safest reversible option and list it clearly. End with: the final findings table, assumptions, what could not be run, and anything I must decide.