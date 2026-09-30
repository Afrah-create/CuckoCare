# CucoCare: central theme system with a persisted System / Light / Dark toggle (prompt for Cursor)

Paste everything below the line into Cursor (Agent mode) in the CucoCare repo.

---

## Role and goal

You are a senior Flutter engineer with strong design-systems experience. Implement a **central theming system** and a **theme mode toggle** for CucoCare (Android only):

- The user can choose **System default**, **Light**, or **Dark**. Default is **System default**.
- The choice is **cached on the device** and applied **before the first frame** (no flash of the wrong theme on launch).
- In System mode the app **follows the phone's dark-mode setting live**, including while the app is open.
- **Theme switching happens in exactly one place: the root `MaterialApp`.** No individual widget knows about light or dark, reads the mode, or branches on brightness. Components only read tokens from `Theme.of(context)`.

Read first: `docs/architecture.md`, `.cursor/rules/architecture.mdc`, everything under `lib/app/theme/`, `lib/app/app.dart`, `lib/bootstrap.dart`, `lib/features/settings/`, and every place in `lib/` that uses `Color(`, `Colors.`, `TextStyle(`, `Brightness`, `platformBrightness`, `isDark`, or `Theme.of(context).brightness`. Follow the existing navigation rules (the router is created once and is never recreated by app state changes).

## Ground rules

- Only new dependency allowed: `shared_preferences` (skip if already added). Ask before adding anything else. Do **not** add `dynamic_color` (Material You would override the brand palette, which is out of scope).
- Do not redesign screens. This task is the theme foundation, the toggle, persistence, and migrating existing screens onto tokens.
- Do not decide the brand palette. Use the existing brand tokens if they exist (for example `brandInk`/`brandCream` or a violet seed). If there are none, define a **provisional** palette in one file, `lib/app/theme/brand_palette.dart`, with a comment that changing the brand colours means editing only that file.

## Architecture

```
lib/app/theme/
  brand_palette.dart        # raw brand colours only. The single place to rebrand
  app_theme.dart            # AppTheme.light() / AppTheme.dark() -> ThemeData
  app_colors.dart           # ThemeExtension<AppColors>: semantic tokens (lerp + copyWith)
  app_typography.dart       # TextTheme and font family constant
  app_spacing.dart          # spacing scale, radii, elevations, durations (static consts)
  component_themes.dart     # all component ThemeData pieces, built from ColorScheme + AppColors
  theme_context.dart        # extension on BuildContext: context.colors, context.text, context.scheme
  themed_system_ui.dart     # status/navigation bar style follows the active theme
lib/features/settings/
  domain/theme_preference_repository.dart   # interface
  data/shared_prefs_theme_preference_repository.dart
  presentation/theme_mode_provider.dart     # Riverpod Notifier<ThemeMode>
  presentation/appearance_section.dart      # the toggle UI
  presentation/theme_mode_selector.dart     # reusable widget
```

### Tokens

- `AppTheme.light()` and `AppTheme.dark()` each build a Material 3 `ColorScheme` from the brand palette (explicit dark values tuned for contrast, not just an inverted seed) plus an `AppColors` extension.
- `AppColors` (implement **`copyWith` and a correct `lerp`** so theme switches animate smoothly) holds semantic tokens Material lacks:
  - Status: `success`, `warning`, `info`, each with `on*` and container variants.
  - Vaccination states: `taskUpcoming`, `taskDueToday`, `taskOverdue`, `taskDone`. These must be distinguishable for colour-blind users, so widgets always pair them with an icon and label (provide a reusable `StatusChip` that enforces this).
  - Sync states: `syncIdle`, `syncSyncing`, `syncOffline`, `syncError`.
  - Brand: `brandInk`, `brandCream`, `splashBackground`, brand gradient stops, glass-surface fill and border (for the auth screens), `scrim`.
- Component themes for: `AppBar`, `NavigationBar`, `NavigationRail`, `Card`, `InputDecoration`, `Filled/Elevated/Outlined/Text` buttons, `IconButton`, `Chip`, `Dialog`, `BottomSheet`, `SnackBar`, `ListTile`, `Switch`, `Checkbox`, `Radio`, `SegmentedButton`, `Divider`, `ProgressIndicator`, `Tooltip`, `PageTransitionsTheme` (keep any existing predictive-back configuration). All defined centrally in `component_themes.dart` so feature widgets need no per-widget styling.
- Spacing, radii, and durations are static constants (they do not vary by brightness) in `app_spacing.dart`. Typography is in `app_typography.dart` with one font family constant (bundled asset font or the system default, never a runtime-downloaded font, because the app is offline-first).
- `theme_context.dart` exposes `context.colors` (the `AppColors` extension), `context.scheme`, and `context.text`. Feature code uses only these.

### Single switching point

```dart
MaterialApp.router(
  routerConfig: ref.watch(routerProvider),          // created once, never rebuilt by theme changes
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: ref.watch(themeModeProvider),          // the only consumer of the mode
  themeAnimationDuration: <zero when the OS "Remove animations" setting is on, else ~200 ms>,
  builder: (context, child) => ThemedSystemUi(child: child!),
);
```

- Use `ThemeMode.system` for System default so Flutter follows the platform brightness and updates **live** (no manual `WidgetsBindingObserver`, no cached `Brightness`).
- `ThemedSystemUi` wraps the app in an `AnnotatedRegion<SystemUiOverlayStyle>` derived from the **current** theme (status-bar and navigation-bar icon brightness, transparent bars). Enable edge-to-edge (`SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)`). Screens handle insets with `SafeArea`/`Scaffold` and do not hard-code paddings for bars.
- **Themed ThemeData objects are built once** (cached static or provider-held), not rebuilt on every `build`.

### Persistence and no-flash startup

- `ThemePreferenceRepository` (domain interface): `Future<ThemeMode> load()`, `Future<void> save(ThemeMode)`. The data implementation uses `shared_preferences` with key `theme_mode` and string values `system` | `light` | `dark`. Unknown or missing values mean `system`. Never throw on read.
- In `bootstrap.dart`, **load the preference before `runApp`** and inject it with a `ProviderScope` override for the initial value of `themeModeProvider`, so the very first Flutter frame already uses the saved theme.
- `themeModeProvider` is a Riverpod `Notifier<ThemeMode>`: `set(ThemeMode)` updates state immediately (optimistic), then persists. If persistence fails, log it and keep the in-memory choice (do not revert or crash).
- The preference is **per device** and **not synced** to Supabase. It survives sign-out, sign-in as another user, and "Full resync". Record this in an ADR.
- Known limitation to document in an ADR: the native splash follows the **system** theme only. If the user's app preference differs from the system setting, there may be a brief background-colour mismatch before the first Flutter frame. Do not try to hack around it.

### Toggle UI

- In **More → Settings → Appearance**: a `ThemeModeSelector` showing three options with icons and labels: **System default** (`brightness_auto`), **Light** (`light_mode`), **Dark** (`dark_mode`). Use a `SegmentedButton` (or a radio list in a dialog if the labels do not fit at large text scales). The selected state must be obvious in both themes and accessible with TalkBack (proper `Semantics` and selected state).
- Under the selector, when System is chosen, show small helper text: "Following your phone's setting (currently Dark)". It must update live when the system setting changes.
- Expose the selector as a **reusable widget** so it can be dropped elsewhere later. Do not add extra toggles to other screens in this task.
- All strings go through localisation (`arb`): "Appearance", "System default", "Light", "Dark", and the helper text.

## Migration: make everything use tokens

1. Audit all of `lib/` (excluding `lib/app/theme/` and tests). Put the findings in `docs/theme-audit.md`: file, line, what hard-coded style it uses, and what token replaces it.
2. Migrate every occurrence. Fix: `Color(0x...)`, `Colors.*`, raw `TextStyle(...)` with hard-coded colour or size, hard-coded `BorderRadius`/padding that should be tokens, `Brightness`/`isDark` branching in widgets, and any `Theme.of(context).brightness` checks (brightness-dependent appearance belongs in the tokens).
3. Tint brand images through `ColorFiltered`/`Image.color` from tokens, never by swapping separate light and dark asset files, unless an asset truly cannot be tinted (then pick it through a theme token accessor, not a brightness check in the widget).
4. The sync status chip, home shell, settings screens, login placeholder, and any dev screens all use `context.colors`/`context.scheme`/`context.text`.

### Enforcement (required)

Add `test/architecture/theme_rules_test.dart` that scans `lib/**` (excluding `lib/app/theme/**` and `*.g.dart`/`*.freezed.dart`) and **fails** on: `Color(0x`, `Colors.`, `Brightness.`, `platformBrightness`, `.brightness ==`, `isDark`, `ThemeMode.` (outside the settings provider, repository, selector, and `app.dart`), and `TextStyle(` with a literal `color:` or `fontSize:`. Allow an explicit, reviewed allow-list file (`test/architecture/theme_rules_allowlist.txt`) for genuine exceptions, each with a written reason. Also update `.cursor/rules/` with a `theme.mdc` rule: "Only the root MaterialApp reads the theme mode. Widgets use context.colors / context.scheme / context.text. No brightness branching in widgets."

## Design-system gallery (dev flavor only)

Add a dev-only "Design system" screen (for example Settings → Developer) that renders every token swatch, text style, and each themed component (buttons, inputs, chips, cards, dialogs, sheets, snackbars, nav bar, status chips for every vaccination and sync state) and includes the `ThemeModeSelector`. It exists to verify the central switching visually and to drive golden tests. It must not ship in prod.

## Tests (all required)

- **Central-switch test:** pump the real app (or the gallery) with a fake preference repository, toggle `themeModeProvider` and assert the `Scaffold` background, `AppBar`, a `FilledButton`, the `NavigationBar`, a `StatusChip`, and an `AppColors` consumer all change, with **no widget-level code involved**.
- **System follow test:** in System mode, change `tester.platformDispatcher.platformBrightnessTestValue` mid-test and assert the UI updates live, and that explicit Light/Dark ignore the platform value.
- **Persistence test:** set Dark, create a fresh `ProviderContainer` with the same fake storage, and assert the initial value is Dark **before** any async work (proves the no-flash startup path). Corrupt or unknown stored values fall back to System. A save failure does not crash and keeps the in-memory choice.
- **Router stability test:** the `GoRouter` instance is identical before and after theme changes, and the navigation stack is preserved.
- **`AppColors` tests:** `lerp` at 0, 0.5, and 1; `copyWith`; both themes define every token.
- **Contrast tests:** compute WCAG contrast ratios in both themes and assert at least 4.5:1 for body text pairs (`onSurface`/`surface`, `onPrimary`/`primary`, `on*Container`/`*Container`, text on status colours) and at least 3:1 for UI components and large text (`outline` vs `surface`, icon colours, selected vs unselected controls).
- **Golden tests:** the gallery in light and dark at 360x800 dp, at text scale 1.0 and 1.3.
- **Reduced motion:** with animations disabled, `themeAnimationDuration` is zero.
- The architecture test above.

## Docs

Create `docs/theming.md`: how tokens are organised, how to add a token or a component theme, how to rebrand (edit `brand_palette.dart`), the single-switch rule, how persistence works, and the do/don't list for widget authors. Add ADRs: (1) theme mode is switched only at the root `MaterialApp`, (2) three-way mode with System default as the default, (3) preference is loaded before `runApp` to avoid a wrong-theme flash, and the native splash limitation, (4) device-level preference, not synced, (5) semantic tokens via `ThemeExtension` with mandatory `lerp`, and no brightness branching in widgets.

## Acceptance criteria

1. `dart run build_runner build`, `flutter analyze`, and `flutter test` pass from a clean checkout, including the architecture test.
2. Choosing Dark in Settings switches the **entire app at once**, with a smooth transition and no restart, including dialogs, bottom sheets, snackbars, the navigation bar, and the status/navigation bar icons.
3. Kill the app and reopen it: the chosen theme is applied from the first Flutter frame, with no flash of the other theme.
4. With System default selected, toggling the phone's dark mode (Quick Settings) while the app is open updates the app live. Explicit Light or Dark ignores the phone setting.
5. The preference persists across app restarts, sign-out, and signing in as another user.
6. `grep` finds no hard-coded colours or brightness checks in `lib/` outside `lib/app/theme/` (enforced by the test).
7. Both themes pass the contrast tests.

## Out of scope

Choosing or redesigning the brand palette, the login screen redesign, Material You dynamic colour, per-screen theme overrides, syncing the theme across devices, and iOS.

## Working style

Commit after each step: (1) audit doc, (2) tokens, `AppColors`, component themes, `AppTheme`, (3) root `MaterialApp` wiring and `ThemedSystemUi`, (4) repository, provider, and no-flash bootstrap, (5) toggle UI and localisation, (6) migrate existing screens onto tokens, (7) architecture test and cursor rule, (8) dev gallery and goldens, (9) remaining tests, (10) docs and ADRs. If something is ambiguous, choose the conservative option, record it in an ADR, and continue. End with assumptions, any allow-listed exceptions with reasons, and anything the design owner still needs to decide (for example final brand colours).