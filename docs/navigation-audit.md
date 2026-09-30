# Navigation audit (Step 0)

## Call sites (pre-refactor)

| File | Line | API | Destination / purpose |
|------|------|-----|------------------------|
| `auth_splash_screen.dart` | 90 | `context.go` | `/login` |
| `auth_splash_screen.dart` | 93 | `context.go` | `/home` |
| `login_screen.dart` | 74, 81 | `context.go` | `/home` (replaces stack after auth) |
| `home_shell.dart` | 49 | `context.go` | `/login` (sign out) |
| `home_shell.dart` | 361–364 | `Navigator.push` + `MaterialPageRoute` | Sync diagnostics (parallel stack) |
| `home_shell.dart` | 373 | `context.push` | `/home/farm-profile` |
| `farm_profile_banner.dart` | 26 | `context.push` | `/home/farm-profile` |
| `farm_setup_screen.dart` | 68, 83 | `context.pop` | Close farm profile |
| `profile_sheet.dart` | 110, 134 | `Navigator.pop` | Close bottom sheet |
| `sync_diagnostics_screen.dart` | 98, 102 | `Navigator.pop` | Dialog buttons |
| `app_router.dart` | 13–14 | `ref.watch(hasAuthSnapshotProvider)` | **Recreates `GoRouter` on auth changes** |

## Root cause: Back closes the app

Verified contributors:

1. **`GoRouter` recreated when auth state changes** — `appRouterProvider` used `ref.watch(hasAuthSnapshotProvider)`, so any auth invalidation rebuilt the router and **wiped navigation stacks**. After `pop`, the platform sometimes had no route left and exited the task. **Fix:** create the router once; bridge auth via `refreshListenable` + `ref.read` in `redirect`.

2. **No per-tab back stack** — `HomeShell` used a local `_index` and `IndexedStack`, not `StatefulShellRoute`. Drill-downs mixed `MaterialPageRoute` (sync diagnostics) with go_router. **Fix:** `StatefulShellRoute.indexedStack` with nested sub-routes; full-screen details on `rootNavigatorKey`.

3. **`context.go('/home')` after login** — acceptable for auth transition, but combined with (1) any later redirect could reset stack. **Fix:** `go('/today')` only on auth boundaries; use `push` for drill-down.

4. **Not observed:** `WillPopScope` blocking back; top-level detail routes without nesting (farm profile was nested but shell was wrong).

## Failing test (regression)

See `test/navigation/back_from_batch_detail_test.dart` — pushes batch detail from Batches tab, simulates system back, expects batches list still visible.
