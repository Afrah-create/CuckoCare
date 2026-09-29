# CucoCare: project scaffold prompt for Cursor

Paste everything below the line into Cursor (Agent mode) at the root of an empty repo.
Before you run it, put `uganda_poultry_vaccination_schedule.json` in the repo root so Cursor can move it into `assets/seed/`.

---

## Role and goal

You are a senior Flutter/Dart engineer with strong Postgres and offline-first sync experience. Scaffold **CucoCare**, an **Android-only** offline-first poultry farm management app for smallholder farmers in Uganda (batches with automatic age calculation, vaccination scheduling and reminders, feed, health, mortality, farm events, sync/backup).

This task is **scaffolding and architecture only**. Do not build feature UIs beyond a minimal shell. The output must compile, pass `flutter analyze`, pass `flutter test`, and run showing a home screen with a sync status indicator.

## Product constraints that drive the design

- Users have unreliable connectivity and limited data plans. **All UI reads and writes go to local SQLite. No screen calls the network.**
- Reminders must fire on the device without a server round-trip.
- Sync is delta-based and low-bandwidth.
- The session must be **cached securely so the app opens and works fully offline**.
- Payments use **MakyPay**. SMS uses **MakyReach**. Both are handled **server-side** (Supabase Edge Functions). The app never holds their API keys.
- Backend is **Supabase** (Postgres, Auth, RLS, RPC, Edge Functions).
- Only the poultry farmer is a user. Keep the UI simple. Users have basic digital literacy.

## Stack

Use `flutter pub add` so versions resolve to current stable. Do not hard-code versions from memory.

- Flutter stable, Dart 3, null-safe, Android only: `flutter create --platforms=android --org com.cucocare --project-name cucocare .` (change org later if needed)
- State/DI: `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`
- Routing: `go_router`
- Local DB: `drift`, `drift_flutter` (or `sqlite3_flutter_libs`), `drift_dev`, `build_runner`
- Models: `freezed`, `freezed_annotation`, `json_serializable`
- Backend: `supabase_flutter`
- Secure storage: `flutter_secure_storage`
- Connectivity: `connectivity_plus`
- Notifications: `flutter_local_notifications`, `timezone`, `flutter_timezone`
- Background: `workmanager`
- Misc: `uuid`, `intl`, `logger`, `collection`, `equatable` (only if needed)
- Dev: `mocktail`, `flutter_lints` (or `very_good_analysis`), `drift_dev`

Do not add other dependencies without asking.

## Android configuration

- `minSdk` 24. Enable core library desugaring (required by `flutter_local_notifications`).
- Product flavors `dev`, `staging`, `prod` with `applicationIdSuffix` for dev and staging and distinct app names.
- Manifest permissions: `INTERNET`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`. **Do not** request `SCHEDULE_EXACT_ALARM`. Use inexact scheduling.
- Register the boot receiver so reminders are restored after reboot.
- Config via `--dart-define-from-file=env/dev.json` (and staging, prod). Commit `env/*.example.json` only. Add real env files to `.gitignore`. Keys: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `ENV_NAME`.

## Architecture

Feature-first Clean Architecture with three layers per feature. Dependencies point inward only: presentation → domain ← data.

```
lib/
  main.dart
  bootstrap.dart                  # init: env, Supabase, Drift, notifications, workmanager
  app/
    app.dart                      # MaterialApp.router
    router/                       # go_router config, auth-aware redirects
    theme/
    l10n/                         # arb files, en now; structure ready for Luganda (lg)
  core/
    config/                       # Env (from dart-define), feature flags
    error/                        # Failure types, Result<T>
    time/                         # Clock abstraction, Africa/Kampala timezone helpers
    logging/
    network/                      # ConnectivityMonitor interface + impl
    utils/
  data_platform/                  # shared infrastructure
    db/
      app_database.dart           # Drift database, migrations
      tables/                     # one file per table
      daos/
    supabase/
      supabase_bootstrap.dart
      secure_local_storage.dart   # custom LocalStorage for supabase_flutter
    sync/
      sync_engine.dart            # interface
      outbox_sync_engine.dart     # implementation
      remote_sync_api.dart        # interface
      supabase_remote_sync_api.dart
      sync_scheduler.dart         # triggers: foreground, connectivity change, debounce after writes
      backoff.dart
    notifications/
      reminder_scheduler.dart     # interface
      local_reminder_scheduler.dart
    payments/
      payment_gateway.dart        # port
      makypay_gateway.dart        # calls Edge Functions only
    sms/
      sms_gateway.dart            # port
      makyreach_gateway.dart      # calls Edge Functions only
  features/
    auth/          {presentation, domain, data}
    farms/         {presentation, domain, data}
    batches/       {presentation, domain, data}   # age calculation lives in domain
    vaccination/   {presentation, domain, data}   # programme templates + task materialisation
    feed/          {presentation, domain, data}
    health/        {presentation, domain, data}
    mortality/     {presentation, domain, data}
    farm_events/   {presentation, domain, data}
    subscription/  {presentation, domain, data}   # entitlements, MakyPay flow (premium)
    settings/      {presentation, domain, data}
    home/          {presentation}                 # shell with bottom nav + sync status
assets/
  seed/uganda_poultry_vaccination_schedule.json   # moved from repo root
supabase/
  config.toml
  migrations/
  functions/
    makypay-checkout/
    makypay-webhook/
    makyreach-send/
    _shared/
  seed.sql
test/
  core/  data_platform/  features/
docs/
  adr/                            # architecture decision records
  architecture.md
.github/workflows/ci.yml
.cursor/rules/
```

Create every folder with a minimal placeholder file or a real starter, so the tree exists in git. Each feature gets `domain/` (entities, repository interface, use-cases), `data/` (repository impl, mappers) and `presentation/` (screens, providers).

## Non-negotiable rules (also write them into `.cursor/rules/architecture.mdc`)

1. Widgets never touch Drift, Supabase, or HTTP. They talk to Riverpod providers that call use-cases/repositories.
2. Repositories read and write **only Drift**. Writes to synced tables also insert an **outbox** row in the **same transaction**.
3. Domain code is pure Dart (no Flutter, Drift, or Supabase imports) and has unit tests.
4. IDs are client-generated UUIDs (prefer v7). Never rely on server-generated IDs.
5. **Store dates, never ages.** Compute batch age at read time from `acquired_on` and `age_at_acquisition_days`, using an injected `Clock`.
6. Append-only tables (`feed_transactions`, `mortality_records`, `health_records`, `farm_events`) are never updated in place. Feed stock is **derived** from transactions, not stored as a mutable quantity.
7. Deletes are soft (`deleted_at`). Sync propagates tombstones.
8. Use `Result<T>`/typed failures at boundaries. No swallowed exceptions. Log with the logger.
9. No secrets in the repo or in the app bundle beyond the Supabase URL and anon key.
10. Small, reviewable commits. Ask before adding dependencies or deviating from this document.

## Local database (Drift)

Synced tables share these columns: `id` (text UUID, PK), `farm_id`, `created_at`, `updated_at`, `deleted_at` (nullable), `server_version` (int, nullable until first sync).

Tables (start with columns that are clearly needed; leave `// TODO` for the rest):
- `farms`, `farm_members`
- `batches`: `name`, `bird_type` (broiler | layer | dual_purpose | local), `initial_count`, `acquired_on`, `age_at_acquisition_days`, `hatchery_vaccinated` (nullable bool), `source`, `status`, `programme_id`, `programme_version`, `notes`
- `programmes`, `programme_steps` (reference data, read-only on device, loaded from the seed JSON and then updated by sync)
- `vaccination_tasks`: `batch_id`, `step_id`, `due_on`, `status` (pending | done | skipped | assumed_done), `done_on`, `product_used`, `notes`
- `feed_items`: `name`, `feed_type`, `unit`, `reorder_level`
- `feed_transactions`: `feed_item_id`, `batch_id` (nullable), `kind` (purchase | usage | adjustment), `quantity`, `unit_cost` (nullable), `occurred_on`
- `health_records`, `mortality_records`, `farm_events`
- `entitlements`: cached plan, status, `valid_until`, `last_verified_at`
- `outbox`: `op_id` (UUID), `table_name`, `row_id`, `op` (upsert | delete), `payload` (json), `created_at`, `attempts`, `last_error`
- `sync_cursors`: `table_name`, `cursor` (last `server_version` seen)
- `auth_snapshot`: single row with `user_id`, `email`/`phone`, `farm_ids`, `last_verified_at`

Set up Drift migrations with `schemaVersion = 1`, plus the migration test scaffolding (`drift_dev schema` export) so future migrations are tested.

## Auth and offline session caching

- Configure `supabase_flutter` with a **custom `LocalStorage` backed by `flutter_secure_storage`** (`secure_local_storage.dart`) so tokens are stored encrypted.
- Keep our own `AuthSnapshot` (Drift plus secure storage) of who is signed in and when the session was last verified online.
- **Routing must not depend on a live token refresh.** If an `AuthSnapshot` exists, open the app in an authenticated, offline-capable state, even when the access token has expired and there is no network.
- **Never sign the user out because of a network error.** Sign out only on an explicit user action, or when the server explicitly rejects the refresh token **while online**.
- If refresh is rejected while online: keep local data and the outbox untouched, show a "please sign in again" prompt, and resume sync after the **same user** signs in. If a **different** user signs in, require an explicit confirmation before wiping local data.
- Add a configurable `offlineGraceDays` (default 30) after which the app asks for an online re-verification. It only blocks premium entitlement checks and sync, not local record keeping. Make this easy to change.
- First-ever login and registration require connectivity. Document this in `docs/architecture.md`.
- Unit-test the session gate with a fake auth client: expired token plus offline must still open the app.

## Sync engine

Define interfaces first, then a working skeleton with tests against a **fake remote**.

- **Push:** read pending `outbox` rows in batches, send to `sync_push(ops jsonb)` (idempotent by `op_id`), delete acknowledged rows, and record `attempts` and `last_error` for failures. Exponential backoff with jitter.
- **Pull:** per table, ask for rows with `server_version > cursor`, paginated. Apply in one Drift transaction, then advance the cursor. Apply tombstones.
- **Conflicts:** insert-only tables have none. Mutable rows use server-side last-write-wins by `server_version`. Never trust device clocks. `vaccination_tasks.status` is monotonic (`done` beats `pending`).
- **Triggers:** app foreground, connectivity change, and debounced after local writes. Do not rely on background sync. Add a best-effort `workmanager` periodic task.
- `ConnectivityMonitor` treats `connectivity_plus` as a hint only. Real reachability is decided by request success or failure.
- Expose `SyncStatus` (idle | syncing | offline | error, pending outbox count, last synced at) via a Riverpod provider and show it in the home shell.
- Behind a `SyncEngine` interface so it can later be swapped (for example for PowerSync).

Tests (with fakes): retry after failure, duplicate delivery is idempotent, killed-mid-push resumes, pull pagination, tombstone handling, offline then online transition.

## Vaccination domain (core feature, do this properly)

- Load `assets/seed/uganda_poultry_vaccination_schedule.json` into `programmes` and `programme_steps` on first run. Server-delivered versions replace it later.
- `MaterialiseVaccinationTasks` use-case: on batch creation, generate `vaccination_tasks` from the programme steps.
  - Hatchery steps (`location = hatchery`) become `assumed_done`, shown as "confirm done at hatchery". They are not reminders.
  - If the batch is registered at age A, steps with `age_days < A` become `assumed_done` for the farmer to confirm. Do not back-fill silently as done.
  - Optional steps default to off. Recurring steps (`recurring` in the JSON) generate tasks forward within a rolling horizon.
- Pure functions with unit tests: `currentAgeDays(batch, clock)`, `dueDate(batch, step)`, `taskState(task, clock)` → upcoming | due_today | overdue | done, using the step's due window.
- Use `Africa/Kampala` for "today" and for reminder times (default 07:00 local).

## Reminders (Android)

- `ReminderScheduler` interface plus `LocalReminderScheduler` using `flutter_local_notifications` and `timezone`.
- Keep only the soonest N (default 50) reminders scheduled. Reconcile on app open, after sync, and after boot.
- Inexact scheduling only. The in-app "Due today" list is the source of truth.
- Request `POST_NOTIFICATIONS` at a sensible moment, not at launch. Handle denial gracefully.

## Payments (MakyPay) and SMS (MakyReach)

I do not have the MakyPay or MakyReach API specs in this prompt. **Do not invent endpoints, payloads, or auth schemes.**

- Define ports in Dart: `PaymentGateway` (create checkout for a plan, poll or read entitlement) and `SmsGateway` (request a reminder or notification SMS). The Android implementations only call **Supabase Edge Functions** with the user's JWT.
- Create the Edge Function folders with typed request/response contracts and `// TODO(MakyPay docs)` / `// TODO(MakyReach docs)` where the provider call goes. Read secrets from `Deno.env` (for example `MAKYPAY_API_KEY`, `MAKYPAY_WEBHOOK_SECRET`, `MAKYREACH_API_KEY`) and document them in `supabase/functions/README.md`. Never commit values.
- `makypay-webhook` must verify the provider signature, be **idempotent**, and update `payments` and `entitlements` server-side. The client never grants itself entitlements.
- Entitlements sync down to the device and are cached in Drift, so premium features work offline until `valid_until` plus a short grace period.
- SMS is server-triggered only, for example a scheduled function that texts due-vaccination reminders to farmers who opted in. Client-side SMS sending is out of scope. Scaffold the opt-in fields and the function skeleton only.
- Put a short "What I need from you" list at the end of your final message asking for the MakyPay and MakyReach docs (auth, create-payment, webhook signing, sender IDs, rate limits).

## Supabase project

Create `supabase/migrations/0001_init.sql` with real, working DDL for the core tables:

- `profiles`, `farms`, `farm_members(farm_id, user_id, role)`, `batches`, `programmes`, `programme_steps`, `vaccination_tasks`, `feed_items`, `feed_transactions`, `health_records`, `mortality_records`, `farm_events`, `entitlements`, `payments` (server-only), `sms_outbox` (server-only).
- Every synced table has `farm_id`, `created_at`, `updated_at`, `deleted_at`, and `server_version bigint`. A shared sequence and a `BEFORE INSERT OR UPDATE` trigger set `server_version` and `updated_at`.
- Index `(farm_id, server_version)` on every synced table.
- **RLS on everything.** Policies check membership via `farm_members`. Use `(select auth.uid())` so it is evaluated once per query. Reference tables (`programmes`, `programme_steps`) are readable by any authenticated user. `payments`, `sms_outbox`, and entitlement writes are service-role only.
- `sync_push(ops jsonb)` and `sync_pull(cursors jsonb, page_size int)` as `SECURITY INVOKER` SQL/PLpgSQL functions so RLS applies. Give them real signatures and clear return shapes, with the bodies implemented for at least `batches` and `vaccination_tasks` and `-- TODO` for the rest.
- `seed.sql` loads the programme data from the JSON (or leave a clear TODO and a script).

## Tooling, quality, docs

- Lints on, `analysis_options.yaml` strict-ish. Format with `dart format`.
- `.github/workflows/ci.yml`: checkout, Flutter setup, `pub get`, `build_runner`, `flutter analyze`, `flutter test`.
- `docs/architecture.md`: layers, offline session behaviour, sync design, conflict policy, how to run against local Supabase (`supabase start`).
- `docs/adr/`: write short ADRs for (1) offline-first with Drift as source of truth, (2) custom outbox sync vs PowerSync, (3) append-only feed stock (this deliberately differs from the concept paper's `FEED.quantity` field), (4) server-side payments and SMS, (5) session caching policy.
- `README.md` with setup and run commands per flavor.

## Acceptance criteria

1. `flutter pub get`, code generation, `flutter analyze`, and `flutter test` all succeed.
2. `flutter run --flavor dev --dart-define-from-file=env/dev.json` launches an Android app with an auth-aware router, a home shell with bottom navigation, and a live sync status indicator.
3. Drift schema v1 exists with migration test scaffolding.
4. Unit tests exist and pass for age calculation, task state, task materialisation (including the hatchery and catch-up rules), the session gate (offline with an expired token), and sync push/pull against the fake remote.
5. The `supabase/` folder contains a valid migration with RLS and the sync RPC signatures, and Edge Function skeletons for MakyPay and MakyReach with typed contracts and TODOs.
6. `.cursor/rules/architecture.mdc` captures the non-negotiable rules.

## Working style

Work in this order and commit after each step: (1) project init, flavors, and config, (2) folder tree and core, (3) Drift schema and DAOs, (4) auth and session caching, (5) sync engine with fake remote and tests, (6) vaccination domain with tests, (7) reminders, (8) Supabase migration and functions, (9) docs, CI, and rules. If something is ambiguous, make the most conservative choice, note it in `docs/adr/`, and continue. List any assumptions and open questions at the end.