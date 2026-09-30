# Login & farm profile

- **Sign in / sign up** → `/today` (dashboard). Farm setup is never forced at login.
- **Incomplete farm profile**: banner on Today + **More → Farm profile** (`/more/farm`). Required: name, district, village, phone; optional: alt phone, notes. Saves via RPC `save_farm_profile` (migration `0005_farm_profile_fields.sql`).
- **Demo session**: skips the banner.
# CucoCare: implement industry-standard navigation (prompt for Cursor)

Paste everything below the line into Cursor (Agent mode) in the CucoCare repo.

---

## Role and goal

You are a senior Flutter engineer who has shipped large Android apps with go_router, Riverpod and Material 3. Implement a **production-grade navigation architecture** for CucoCare (Android only) modelled on how apps like WhatsApp, Gmail and Google Drive behave.

**Current bug to fix first:** pressing Back on a pushed screen closes the whole app instead of returning to the previous screen. The navigation graph is not properly defined. Do not guess at the cause. Audit, reproduce, explain, then fix.

Read first: `docs/architecture.md`, `.cursor/rules/architecture.mdc`, and everything under `lib/app/router/`, `lib/features/home/`, and every call site of `context.go`, `context.push`, `Navigator.`, `GoRouter`, `MaterialPageRoute`, and `PopScope`/`WillPopScope`.

## Step 0: Audit and diagnosis (do this before changing anything)

1. List every navigation call in `lib/` (file, line, call type, destination). Put the table in `docs/navigation-audit.md`.
2. State the root cause of "Back closes the app". Likely candidates, verify each rather than assuming: (a) drill-down screens opened with `context.go(...)` which **replaces** the stack so nothing is left to pop; (b) the bottom-nav shell is a plain widget with an index instead of a `StatefulShellRoute`, so there is no per-tab back stack; (c) detail routes declared as top-level siblings instead of nested sub-routes; (d) `GoRouter` recreated on auth/state changes, resetting the stack; (e) a `WillPopScope`/`PopScope` that blocks or forces exit.
3. Add a failing widget test that reproduces the bug before fixing it.

## Target navigation model

### Structure

- **Bottom navigation bar** (Material 3 `NavigationBar`) with 5 top-level destinations. Each has its **own independent back stack**, and its state (scroll position, filters, form drafts) is preserved when switching tabs. Use go_router's `StatefulShellRoute.indexedStack`.
  1. **Today**: due and overdue vaccination tasks, alerts, quick actions. Shows a badge with the overdue count.
  2. **Batches**: list, detail, vaccination schedule per batch.
  3. **Feed**: items, stock, transactions.
  4. **Records**: health, mortality, farm events (segmented or sub-tabs inside the screen).
  5. **More**: farm profile, sync diagnostics, subscription, settings, sign out.
- **Auth flow is outside the shell**: splash, login, sign up, forgot password.
- **Drill-down screens hide the bottom bar** (they open on the root navigator with `parentNavigatorKey: rootNavigatorKey`), as WhatsApp does for a chat. Top-level tab roots show the bar.
- **Create/edit flows** (add batch, record mortality, and so on) are full-screen routes on the root navigator. Short confirmations and pickers use modal bottom sheets or dialogs with `useRootNavigator: true`.
- On tablets and foldables (width >= 600 dp) show a `NavigationRail` instead of the bar, using the same shell and branches.

### Route tree (nested sub-routes, so `go()` to a deep path builds a sensible back stack)

```
/splash
/auth/login
/auth/signup
/auth/forgot-password
/today
/batches
  /batches/new                     (root navigator, full screen)
  /batches/:batchId
    /batches/:batchId/edit         (root navigator)
    /batches/:batchId/vaccinations
      /batches/:batchId/vaccinations/:taskId
/feed
  /feed/items/:itemId
  /feed/items/:itemId/transactions/new
/records
  /records/health/new
  /records/mortality/new
  /records/events/new
/more
  /more/farm
  /more/sync                       (diagnostics)
  /more/subscription
  /more/settings
```

Adjust names to match existing features, but keep the nesting principle. Use **typed routes** with `go_router_builder` (`@TypedGoRoute`, `@TypedStatefulShellRoute`). You have approval to add `go_router_builder` as a dev dependency. Route parameters are typed, and no feature code builds path strings by hand.

### Back-button behaviour (Android, implement exactly)

1. Back on a pushed screen pops to the previous screen **in the same stack**.
2. Back on a **non-start tab root** switches to the **Today** tab (the start destination), not exit.
3. Back on the **Today root** exits the app. No double-tap-to-exit dialog.
4. Tapping the **already-selected tab** pops that tab to its root. Tapping it again at the root scrolls its main list to top (expose a `ScrollToTop` hook via a provider).
5. Forms with unsaved input wrap in `PopScope(canPop: !isDirty, ...)` and show a confirm-discard dialog. Use `PopScope`, never `WillPopScope`.
6. Modal sheets and dialogs are dismissed by Back before any route is popped.
7. Enable Android predictive back: set `android:enableOnBackInvokedCallback="true"` in the manifest application tag and use `PredictiveBackPageTransitionsBuilder` for Android in the central `PageTransitionsTheme` (in `lib/app/theme/`). Tab switches use a fade-through transition.

### Forward vs replace: one rule, enforced

- **`context.push` / typed `.push(context)`**: drill-down and create flows (anything that should have a Back target).
- **`context.go` / typed `.go(context)`**: switching tabs, auth transitions (login to home, sign out to login), and resolving deep links or notification taps. **Never `go` from a list to its own detail.**
- **`context.pop<T>()`** to return, optionally with a result. No global "result" state for navigation results.
- After a successful create/edit, `pop` back (with a result if needed). Do not `go` back to the list.
- No raw `Navigator.of(context).push` and no `MaterialPageRoute` anywhere in `lib/features`. Add `test/architecture/no_raw_navigation_test.dart` that scans `lib/features/**` and fails on `Navigator.`, `MaterialPageRoute`, `WillPopScope`, or `context.go(` used with a detail path.

### Router construction and auth

- Provide `GoRouter` via a Riverpod provider **created once**. It must never be recreated when auth or app state changes (this resets the stack). Use `refreshListenable` bridging Riverpod state (a small `ChangeNotifier` that listens to the auth gate provider).
- The `redirect` uses the **existing offline-capable session gate**: an `AuthSnapshot` counts as signed in even with an expired token and no network. Loading state goes to `/splash`; signed out goes to `/auth/login?from=<encoded original location>`; signed in and on an auth route goes to `/today` (or `from`).
- Sign out: `go('/auth/login')` and clear the tab stacks, so Back from login cannot return to the app. Login success: `go('/today')`, so Back from Today exits instead of returning to login.
- Do not put business logic in the router. It asks the gate provider and nothing else.
- Keep `navigatorKey`s as top-level constants in `lib/app/router/navigator_keys.dart` (`rootNavigatorKey` plus one per branch).

### Deep links and notification taps

- Reminder notification payloads carry a typed deep-link path (for example `/batches/<id>/vaccinations/<taskId>`).
- Handle **cold start** (`getNotificationAppLaunchDetails`) and **warm/foreground taps**. Route through a single `DeepLinkHandler` that waits until the session gate is resolved, then calls `router.go(path)`. Because of the nested route tree, Back from that screen goes to the batch, then the batch list, then exits. It does not exit straight away.
- Register a custom scheme `cucocare://` (per flavor, using the flavor's application id suffix where needed) in `AndroidManifest.xml` for auth callbacks (email confirmation and password reset) and document the Supabase redirect URL settings in `docs/architecture.md`. If a deep link arrives for a user who is not signed in, go to login with `from=` and resume afterwards.
- Unknown or malformed links go to a friendly `NotFoundScreen` with a button to `/today`. No crashes.

### State restoration (important on low-RAM Android phones)

Android may kill the app in the background. Set `restorationScopeId` on the router and each `StatefulShellBranch`. Restore the selected tab and each branch's location. Screens with filters or drafts must keep them across process death where feasible (use `RestorationMixin` or `RestorableProperty` for the few that matter, for example the add-batch form).

### Central theme integration

All navigation chrome (NavigationBar, NavigationRail, AppBar, page transitions, dialog and bottom-sheet shapes) gets its look from the central theme in `lib/app/theme/`. No hard-coded colours, sizes, or text styles in navigation widgets. If the theme does not exist yet, add the smallest themed component definitions (`NavigationBarThemeData`, `NavigationRailThemeData`, `PageTransitionsTheme`) and leave the rest to the theme task.

## Implementation layout

```
lib/app/router/
  app_router.dart            # routerProvider (created once), redirect, refreshListenable
  navigator_keys.dart
  routes/                    # typed routes, one file per feature area
  deep_link_handler.dart
  router_refresh.dart        # Riverpod to ChangeNotifier bridge
lib/app/shell/
  app_shell.dart             # NavigationBar / NavigationRail, badge, tab re-tap behaviour
  back_behavior.dart         # PopScope logic for non-start tabs
lib/app/widgets/
  not_found_screen.dart
  discard_changes_scope.dart # reusable dirty-form PopScope wrapper
```

Every existing screen must be moved onto the new routes. No orphaned screens, and no screen reachable only through ad hoc `Navigator` calls.

## Tests (all required)

Use `go_router`-aware widget tests with a test harness that builds the real router and a fake auth gate:

- **Regression for the reported bug:** from Batches, push a batch detail, press Back, and you are on the Batches list (not exited).
- Back on a non-start tab root goes to Today. Back on Today exits (verify the `SystemNavigator.pop` platform call).
- Per-tab stacks: drill into Batches, switch to Feed and back, and the Batches detail is still there with scroll position preserved.
- Re-tap of the selected tab pops to its root.
- Login success then Back exits (does not show login). Sign out then Back does not show the app.
- Deep link `/batches/1/vaccinations/9` builds the stack. Back goes to the batch, then the list, then Today.
- Notification payload routing for cold start and warm start, including when the session gate is still loading.
- Unsigned user hitting a deep link is sent to login with `from` and resumed after login.
- `PopScope` dirty-form dialog: cancel stays, discard pops.
- Router is not recreated across auth state changes (assert identity).
- `NavigationRail` appears at width >= 600 and `NavigationBar` below it, with the same branch state.
- Architecture test forbidding raw navigation (above).

Also write a **manual QA checklist** in `docs/navigation-qa.md` to run on a real phone with both 3-button and gesture navigation: each tab, nested detail, create flow, notification tap, kill-and-restore, rotate.

## Docs

Update `docs/architecture.md` with the route tree (Mermaid), the forward-vs-replace rule, the back-behaviour table, and the deep-link flow. Add ADRs: (1) `StatefulShellRoute` with a stack per tab, (2) detail screens hide the bottom bar, (3) typed routes via `go_router_builder`, (4) router created once with `refreshListenable`, (5) back at a non-start tab returns to Today. Update `.cursor/rules/` with the forward-vs-replace rule and the "no raw Navigator" rule.

## Acceptance criteria

1. The reported bug is reproduced by a test, then fixed, and the test passes.
2. `dart run build_runner build`, `flutter analyze`, and `flutter test` all pass.
3. On a real Android device: Back behaves exactly as in the back-button table, with both gesture and 3-button navigation, and predictive back animation shows on Android 14 and later.
4. Tapping a vaccination reminder notification opens the right task screen from a killed app, and Back walks up the stack before exiting.
5. No screen uses raw `Navigator` calls. The architecture test enforces it.
6. No hard-coded styles in navigation widgets.

## Out of scope

Login and general theme redesign (separate task), new feature screens beyond placeholders needed to fill the route tree, and web/iOS behaviour.

## Working style

Commit after each step: (0) audit doc and failing test, (1) navigator keys, typed routes, and router provider, (2) `StatefulShellRoute` and shell UI, (3) move existing screens onto nested routes and apply the forward-vs-replace rule, (4) auth redirects and sign-in/out behaviour, (5) back behaviour, tab re-tap, predictive back, (6) deep links and notification handling, (7) state restoration, (8) adaptive rail, (9) tests, (10) docs and ADRs. If something is ambiguous, choose the conservative option, record it in an ADR, and continue. End with assumptions and deviations.