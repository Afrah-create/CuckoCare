# CucoCare architecture

Android-only, offline-first poultry farm management for smallholder farmers in Uganda.

## Layers

Feature-first clean architecture:

- **Presentation** — Flutter widgets, Riverpod providers, `go_router`.
- **Domain** — pure Dart entities, repository interfaces, use-cases.
- **Data** — Drift repositories, mappers, outbox writes.

Dependencies point inward: presentation → domain ← data.

## Local source of truth

All UI reads and writes go to **SQLite via Drift**. No screen calls the network directly.

Repositories persist to Drift only. Mutations on synced tables enqueue an **outbox** row in the same transaction for delta sync.

## Offline session

- Supabase Auth session is persisted with **encrypted** `flutter_secure_storage` (`SecureLocalStorage`).
- An **AuthSnapshot** row in Drift records the signed-in user and farm membership for routing.
- Routing does **not** depend on live token refresh. If a snapshot exists, the app opens in an authenticated, offline-capable state.
- Users are never signed out because of network errors—only on explicit sign-out or explicit refresh rejection **while online**.
- **First login/registration requires connectivity** (no initial snapshot without a successful online auth).
- `offlineGraceDays` (default 30, via `Env`) limits premium checks and sync after long offline periods; local record keeping continues.

## Sync

- **Push:** pending outbox → `sync_push(ops jsonb)` (idempotent by `op_id`).
- **Pull:** per-table cursors on `server_version` → `sync_pull(cursors, page_size)`.
- Triggers: foreground, connectivity hint + successful ping, debounced after writes, best-effort Workmanager periodic task.
- Conflicts: last-write-wins by `server_version` for mutable rows; vaccination `done` is monotonic over `pending`.

## Running locally

```bash
cp env/dev.example.json env/dev.json   # fill Supabase URL + anon key
flutter pub get
dart run build_runner build
flutter run --flavor dev --dart-define-from-file=env/dev.json
```

Supabase backend:

```bash
supabase start
supabase db reset   # applies migrations + seed
```

## Vaccination

Programmes are seeded from `assets/seed/uganda_poultry_vaccination_schedule.json` on first launch. Domain rules:

- Store **dates**, compute age at read time with injected `Clock` and `Africa/Kampala` calendar days.
- Hatchery steps → `assumed_done` (confirm at hatchery, no reminders).
- Steps before registration age → `assumed_done` for farmer confirmation.
- Optional steps off by default; recurring steps generate tasks within a rolling horizon.
