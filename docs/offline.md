# CucoCare: implement the offline sync backend (prompt for Cursor)

Paste everything below the line into Cursor (Agent mode) in the CucoCare repo.

---

## Role and goal

You are a senior engineer with deep Postgres, Supabase and offline-first mobile sync experience. Implement the **production-grade offline sync system** for CucoCare on top of the existing scaffold: the Supabase side (schema, triggers, RPCs, RLS, tests) and the Flutter side (outbox, engine, remote API, scheduler, diagnostics).

Read first: `docs/architecture.md`, all ADRs in `docs/adr/`, `.cursor/rules/architecture.mdc`, `supabase/migrations/0001_init.sql`, and everything under `lib/data_platform/sync/` and `lib/data_platform/db/`. **Follow the existing rules.** Where this document contradicts the existing code or ADRs, this document wins. Record each such change in a new ADR.

## Non-negotiables

- The local Drift DB stays the source of truth for the UI. Screens never call the network.
- Correctness over cleverness: idempotent, resumable, safe to kill at any point.
- The server never trusts the client for: `farm_id` on existing rows, `server_version`, `updated_at`, ownership, or roles.
- Never sign the user out or wipe local data because of a sync failure.
- Do not edit migrations that have already been applied to a remote project. **Add new migration files (`0002_...`, `0003_...`).** If `0001` was only ever run locally you may leave it and layer on top anyway.
- No new dependencies without asking.

## Design decisions (implement exactly this)

### 1. Per-scope commit-ordered version counters (replaces the global sequence)

A global sequence is **unsafe for cursors**: sequence values are assigned in call order, not commit order, so a client can advance its cursor past a row that commits later and **miss it forever**. Fix it:

- Table `sync_counters(scope text primary key, last_version bigint not null)`.
- Scope is the farm id (as text) for farm data, and the constant `'reference'` for reference tables (`programmes`, `programme_steps`).
- A `BEFORE INSERT OR UPDATE` trigger on every synced table does an atomic upsert on `sync_counters` (`insert ... on conflict (scope) do update set last_version = sync_counters.last_version + 1 returning last_version`) and assigns `NEW.server_version`, and sets `NEW.updated_at = now()`. The trigger function is `SECURITY DEFINER` with `set search_path = ''`.
- The counter row lock is held until commit, so writes within a scope **commit in version order** and versions are **gap-free from a reader's view**. That makes "give me everything with `server_version > cursor`" safe.
- Consequence: **a client keeps one cursor per scope**, not per table. Add a comment block in the migration explaining this.

### 2. Config-driven tables

Create `sync_table_config(table_name text primary key, kind text check (kind in ('mutable','append_only','reference')), scope_kind text check (scope_kind in ('farm','reference')), writable_columns text[] not null)`. `sync_push` and `sync_pull` use this table with `format()`/`%I` dynamic SQL so adding a table is a config row plus DDL. Column allow-lists are the only columns a client may write. Never accept `server_version`, `updated_at`, or (for existing rows) `farm_id`.

### 3. Push protocol

`sync_push(p_ops jsonb) returns jsonb`, `SECURITY INVOKER` (RLS applies). Each op: `{op_id, table, row_id, op: 'upsert'|'delete', payload, client_created_at}`. Process ops **in array order**, each inside its own subtransaction (`BEGIN ... EXCEPTION WHEN OTHERS`) so one bad op never rolls back the rest.

Per op:
1. **Idempotency:** `sync_ops_applied(op_id uuid primary key, user_id uuid, applied_at timestamptz, result jsonb)`. `INSERT ... ON CONFLICT DO NOTHING`. If it already exists, return the stored result with `status:'duplicate'`.
2. **Authorisation:** the caller must be a member of the row's farm with role in `owner, manager, worker` (`viewer` is read-only). Membership check plus RLS.
3. **Apply by kind:**
   - `append_only`: insert; on conflict on `id` do nothing and report `applied` with the existing `server_version`. Never update.
   - `mutable`: upsert with row-level last-write-wins by arrival. `farm_id` is immutable after insert. `delete` sets `deleted_at = now()` (soft delete).
   - `vaccination_tasks.status` is **monotonic**: implement `task_status_rank(text)` (pending=0, assumed_done=1, skipped=2, done=3) and never let a lower rank overwrite a higher one. Equal rank falls back to LWW for the other fields. Document this.
   - `farms`: special handler. If the id does not exist, create it with `created_by = auth.uid()` **and** insert the owner row in `farm_members` in the same op. If it exists, require owner/manager. `farm_members` is **not client-writable** (invites are out of scope).
4. Return per-op `{op_id, status: 'applied'|'duplicate'|'rejected', server_version, row, error_code, retryable}`. Include the authoritative `row` so the client can update its local `server_version` without a pull. Classify errors: FK violation, deadlock, serialization failure → `retryable:true`. RLS/permission, validation, check-constraint, unknown table → `retryable:false`.
5. Limit: reject a call with more than 200 ops or an oversized payload with a clear error.

### 4. Pull protocol

- `sync_bootstrap() returns jsonb`: for `auth.uid()`, return memberships, farms, and the current head version of each scope (each farm plus `'reference'`). This is how a fresh device learns its farms.
- `sync_head(p_scopes text[]) returns jsonb`: `{scope: last_version}`. Tiny payload. The client calls it first and **skips pulling** when the head equals its cursor (saves mobile data).
- `sync_pull(p_scope text, p_since bigint, p_limit int default 500) returns jsonb`: one **single ordered stream across all tables in the scope**, ordered by `server_version`, capped at `p_limit` (max 1000), shape `{rows:[{table, server_version, row}], next_cursor, has_more, epoch}`. Build it with dynamic `UNION ALL` from `sync_table_config`. Include soft-deleted rows (tombstones). RLS applies (`SECURITY INVOKER`). Verify membership explicitly and return an error for foreign scopes.
- `epoch`: a value in `sync_meta` that operators bump after a restore or reset. If the client sees a different epoch it must reset its cursors and re-hydrate, **without touching unsynced outbox rows**.

### 5. Schema completion

Add, with the same base columns and triggers as the existing tables: `feed_items`, `feed_transactions`, `health_records`, `mortality_records`, `farm_events` (real DDL, not TODOs). Add CHECK constraints (positive quantities, valid enums, `kind` in purchase/usage/adjustment), FKs, and indexes `(farm_id, server_version)` on every synced table plus useful lookups (`batch_id`, `due_on`). Reference tables are readable by any authenticated user, writable only by the service role.

RLS: use `(select auth.uid())` inside policies. Direct client `INSERT/UPDATE/DELETE` on synced tables should be **revoked** for `authenticated`. All client writes go through `sync_push`. Since `sync_push` is INVOKER, grant the minimum needed and prove it works in the pgTAP tests.

### 6. Client outbox

- Extend `outbox`: `state` (pending | in_flight | failed | blocked), `lease_until`, `retryable`, `error_code`, `next_attempt_at`. Keep `op_id` stable for the life of an op.
- One helper, e.g. `AppDatabase.writeSynced(...)`, performs the row write **and** the outbox insert in a **single Drift transaction**. Every repository uses it. Add a lint-style test that fails if a synced DAO write bypasses it.
- **Coalesce** consecutive pending (not in-flight) upserts to the same `(table,row)` into one op with the latest payload. Never coalesce across an in-flight op. A delete after upserts collapses to the delete (keep the row's tombstone).
- Claim batches with a lease (`lease_until`) so a crashed run's ops become claimable again.
- Ops the server rejects with `retryable:false` go to `failed` (dead letter) and **never block the queue**. Ops that depend on a failed parent become `blocked`.

### 7. Remote API and errors

- Implement `SupabaseRemoteSyncApi` using `client.rpc(...)` for `sync_bootstrap`, `sync_head`, `sync_pull`, `sync_push`. Timeouts (about 20s push, 15s pull), and map everything to a sealed `SyncFailure`: `Offline`, `Timeout`, `Server(retryable)`, `AuthRequired`, `Rejected`, `SchemaMismatch`.
- On a JWT-expired/401: attempt **one** token refresh **only if the network is reachable**. If refresh is rejected, emit `AuthRequired`. The existing session rules apply: keep data and outbox, prompt for sign-in, no wipe.
- If there is no real session (the dev offline demo session), the engine **no-ops** and reports `SyncStatus.signedOutDemo`.

### 8. Engine algorithm

Single-flight (one run at a time, via a mutex; concurrent triggers coalesce into one follow-up run). One run:

1. Check reachability via a cheap `sync_head` call (not `connectivity_plus` alone).
2. If never hydrated (or epoch changed): run **bootstrap** then hydrate `reference` and each farm from cursor 0.
3. **Push:** claim up to 100 ops (cap about 256 KB), send, apply results: delete `applied`/`duplicate` ops, write the returned `row.server_version` into the local row, mark rejected ops per §6, schedule retryable ones with exponential backoff and jitter (cap 15 min). Loop until the queue is drained or a failure occurs.
4. **Pull:** `sync_head` for all scopes, pull only scopes whose head is beyond the cursor, page until `has_more=false`. Apply each page in **one Drift transaction**, then advance that scope's cursor in the **same transaction**.
5. Reschedule reminders if any `vaccination_tasks` changed. Publish `SyncStatus` (idle | syncing | offline | error | authRequired | signedOutDemo, plus pending count, failed count, last synced at, last error).

**Apply rules for pulled rows:**
- Upsert only if `incoming.server_version > local.server_version` (or the row is absent). Never downgrade.
- If the row has a **pending or in-flight outbox op**, do **not** overwrite local fields. Keep the local edit, advance the cursor, and let the push ack deliver the authoritative version.
- Tombstones (`deleted_at` set) become local soft-deletes.
- Disable FK enforcement during page apply (`PRAGMA defer_foreign_keys`) since rows arrive in version order, not dependency order. Validate integrity at the end of the transaction in debug builds.
- `vaccination_tasks.status` uses the same monotonic rule on the client.

### 9. Scheduler and triggers

Keep the existing `SyncScheduler` and wire: app resume, connectivity regained, debounced (about 3 s) after local writes, after successful sign-in, and a best-effort Workmanager periodic task (about 6 h, network required, battery not low). The Workmanager isolate must initialise Drift and Supabase independently and share the same single-flight guard through a DB-level lock row (`sync_lock` with lease) so the foreground and background runs never overlap.

### 10. Hydration and restore

A new phone with an existing account must fully restore. Show a first-sync progress state ("Restoring your farm data... N records") driven by the pull pages. The UI must stay usable for already-hydrated scopes. Add a **"Full resync"** action that resets cursors but keeps the outbox.

### 11. Diagnostics screen (Settings → Sync)

Show: status, last synced, pending/failed counts, cursors per scope, and a list of failed ops (table, row, error code) with **Retry** and **Discard** (discard requires confirmation and logs). Keep a local ring buffer `sync_events` (last 200 entries) for debugging. Make it plain and simple. It is mostly for support.

### 12. Reference implementation scope

Fully wire `batches` and `vaccination_tasks` end-to-end (repository → `writeSynced` → outbox → push → pull → apply). Build a small **`SyncedTable<T>` mapper abstraction** (`toPayload`, `fromRemote`, `tableName`, `kind`) and migrate the other tables (feed_items, feed_transactions, health_records, mortality_records, farm_events, farms) onto it with minimal code, so adding a table is mechanical.

### 13. Reference data seeding

The seed JSON in `assets/seed/` may be a placeholder. **Do not treat it as authoritative.** Add `tool/generate_seed.dart` that reads `assets/seed/uganda_poultry_vaccination_schedule.json` and emits `supabase/seed.sql` for `programmes` and `programme_steps` (with a `version` column and stable ids). Fail with a clear error if the JSON lacks the expected keys (`programs.broiler.steps`, `programs.layer.steps`, `programs.layer.recurring`).

## Tests (all required)

**Postgres (pgTAP via `supabase test db`):**
- RLS isolation: user A cannot read, write, or pull user B's farm; viewers cannot push.
- `sync_push`: idempotent on repeated `op_id`; per-op isolation (a bad op does not roll back good ones); append-only never updates; immutable `farm_id`; monotonic task status; farm creation adds the owner membership; oversized call rejected.
- `sync_pull`: ordering by `server_version`, pagination boundaries, tombstones included, foreign scope rejected.
- **Concurrency:** two concurrent transactions writing the same farm produce versions that are committed in order (no gap a reader can miss). Include a test that would have failed with a global sequence.

**Dart:**
- Outbox: `writeSynced` atomicity (row and op roll back together), coalescing rules, lease expiry reclaim, dead-letter and blocked transitions.
- Engine (with a fake remote): retry with backoff, duplicate delivery, killed mid-push then resume, pagination, tombstones, epoch reset, pending-edit-not-overwritten, no-op in demo session, single-flight under concurrent triggers.
- **Remote contract tests:** one shared test suite that runs against both `FakeRemoteSyncApi` and (opt-in via env var) a real local Supabase, so the fake cannot drift from the real semantics.
- **Two-device convergence test:** two in-memory Drift DBs plus one shared remote; run several hundred randomised operations (create, edit, delete, offline periods, syncs in random order, killed runs). After a final sync on both, assert both DBs equal the server (excluding soft-delete-only differences). Use a fixed seed and print it on failure.

## Docs

Update `docs/architecture.md` (sync section, sequence diagram in Mermaid, conflict table) and add ADRs: (6) per-scope commit-ordered counters instead of a global sequence, (7) config-driven sync tables, (8) row-level LWW and monotonic task status (list the known limitation: concurrent edits to different fields of one row on two devices lose one edit), (9) single stream per scope with `sync_head` skip, (10) dead-letter policy.

## Acceptance criteria

1. `supabase db reset` applies all migrations and seeds without errors, and `supabase test db` passes.
2. `flutter analyze` is clean and `flutter test` passes, including the convergence test.
3. With a real Supabase session on the dev flavor: create a batch offline, go online, and it appears in Postgres with tasks. Edit it on the server, and the edit arrives on the device. Kill the app mid-sync, restart, and no duplicate rows and nothing lost.
4. Airplane mode for days does not degrade local use. The outbox drains on reconnect.
5. A fresh install signing into an existing account restores all data with visible progress.
6. The diagnostics screen shows accurate counts and lets me retry or discard failed ops.

## Out of scope

Realtime subscriptions, payments/SMS, sign-in UI, farm invitations, field-level merge, attachments/photos. Do not start these.

## Working style

Commit after each step, in this order: (1) migration `0002` counters, config, schema completion; (2) `sync_push`; (3) `sync_pull`, `sync_head`, `sync_bootstrap`; (4) pgTAP tests; (5) Drift changes and `writeSynced`; (6) remote API and errors; (7) engine; (8) apply rules and hydration; (9) scheduler and Workmanager; (10) diagnostics screen; (11) client tests and convergence test; (12) docs and ADRs. If something is ambiguous, choose the conservative option, note it in an ADR, and continue. End with a list of assumptions and any deviations from this document.