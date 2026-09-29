# CucoCare

Offline-first Android poultry farm management for smallholder farmers in Uganda (batches, vaccination schedules, sync, reminders).

## Prerequisites

- Flutter stable (Dart 3)
- Android SDK (minSdk 24)
- Optional: [Supabase CLI](https://supabase.com/docs/guides/cli) for local backend

## Setup

```bash
cp env/dev.example.json env/dev.json
# Edit env/dev.json with your SUPABASE_URL and SUPABASE_ANON_KEY

flutter pub get
dart run build_runner build
```

## Run (flavors)

```bash
# Dev
flutter run --flavor dev --dart-define-from-file=env/dev.json

# Staging
flutter run --flavor staging --dart-define-from-file=env/staging.json

# Production
flutter run --flavor prod --dart-define-from-file=env/prod.json
```

On first launch in **dev**, use **Continue with offline demo session** on the sign-in screen to reach the home shell with sync status.

## Quality

```bash
flutter analyze
flutter test
```

Drift schema export (for migration tests):

```bash
dart run drift_dev schema dump lib/data_platform/db/app_database.dart test/drift/schema_v1/
```

## Docs

- [Architecture](docs/architecture.md)
- [ADRs](docs/adr/)
- [Supabase functions](supabase/functions/README.md)
