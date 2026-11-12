# CucoCare

Offline-first Android poultry farm management for smallholder farmers in Uganda, plus a vet portal in the same app (batches, vaccination, feed, health incidents, Case Radio messaging, sync, reminders).

**Start here:** [docs/overview.md](docs/overview.md) — product, architecture, tech stack, and every feature.

## Prerequisites

- Flutter stable (Dart 3)
- **JDK 17** with `javac` (Ubuntu: `sudo apt install openjdk-17-jdk`). A JRE-only Java 25 install will fail Gradle with `JAVA_COMPILER`.
- Android SDK (minSdk 24)
- Optional: [Supabase CLI](https://supabase.com/docs/guides/cli) for local backend

## Setup

```bash
cp .env.example .env
# Edit .env with Supabase URL, anon key, and service role (server-only)

dart run tool/sync_env.dart dev   # writes env/dev.json for Flutter (no service role)

flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Run (flavors)

```bash
# Dev (syncs .env → env/dev.json first)
./scripts/run_dev.sh

# Or manually after editing .env:
dart run tool/sync_env.dart dev
flutter run --flavor dev --dart-define-from-file=env/dev.json

# Staging
flutter run --flavor staging --dart-define-from-file=env/staging.json

# Production
flutter run --flavor prod --dart-define-from-file=env/prod.json
```

On first launch in **dev**, use **Continue with offline demo session** on the sign-in screen to reach the home shell with sync status.

## Release APK (under 100MB)

GitHub rejects files ≥ 100MB. **Do not commit APKs.** Build a **release** split APK (phone ABIs only) and attach it to a [GitHub Release](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository).

```bash
chmod +x scripts/build_apk.sh
./scripts/build_apk.sh prod
```

That runs:

```bash
flutter build apk --release --flavor prod \
  --dart-define-from-file=env/prod.json \
  --split-per-abi
```

Outputs (each should be well under 100MB):

- `build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk` — most phones (upload this)
- `build/app/outputs/flutter-apk/app-armeabi-v7a-prod-release.apk` — 32-bit phones

**Do not upload a debug APK.** Debug builds include the Dart kernel blob and extra native libs and routinely exceed 100MB.

Release signing currently uses the debug keystore (`android/app/build.gradle.kts`). Replace that before a Play Store upload.

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

- [Overview](docs/overview.md) — architecture, stack, and features
- [Architecture](docs/architecture.md) — sync protocol
- [Case Radio](docs/case-messaging.md)
- [Vet directory](docs/vet-directory.md)
- [ADRs](docs/adr/)
- [Supabase functions](supabase/functions/README.md)
