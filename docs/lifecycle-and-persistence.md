# Lifecycle and persistence

## State tiers

| Tier | What | Where | Survives |
|------|------|-------|----------|
| 1. Domain data | batches, tasks, feed, health, … | Drift (+ outbox) | everything |
| 2. Durable preferences | theme mode, … | `shared_preferences` | force-stop |
| 3. Drafts | half-filled forms | Drift `form_drafts` (planned) | 14 days, local |
| 4. Ephemeral UI | tab, stack, scroll, filters | Flutter restoration | rotation, background, process death |
| 5. In-memory | providers, images | RAM | rotation, brief background |

## Rules for developers

- Save domain data on every meaningful action (Drift + outbox).
- Only `AppLifecycleService` observes lifecycle; register `Flushable` for debounced work.
- Only `bootstrap.dart` calls `SystemChrome.setPreferredOrientations` (`kSupportedOrientations`).
- Do not read `MediaQuery` in `initState` under `lib/features/`.
- Shell keeps one tree: `StatefulNavigationShell` stays in the same `Expanded` slot; chrome toggles with `Offstage`.
- Use `kampalaTodayProvider` for calendar-day logic; it refreshes on resume.

## Orientation

`lib/core/platform/supported_orientations.dart` — all orientations, applied in `bootstrap()`.

## Adding restorable UI

Set `restorationScopeId` on scrollables and use `RestorationMixin` for filters; store ids/primitives only.

## Brand assets

Logo, splash, and launcher pipeline: see `docs/theming.md` and `tool/generate_brand_assets.dart` (not lifecycle).
