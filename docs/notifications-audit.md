# CucoCare: make the whole app responsive from one central place (prompt for Cursor)

Paste everything below the line into Cursor (Agent mode) in the CucoCare repo.

---

## Role and goal

You are a senior front-end engineer who has built adaptive Android apps that stay neat from a 320 dp-wide small phone to a 10-inch tablet, in portrait, landscape, split-screen, and on foldables. CucoCare (Android only) is **only responsive on the auth pages**. Every other screen breaks, wastes space, overflows, or looks unfinished when the device is rotated to landscape or the screen is small or large.

Fix this **structurally, not screen by screen**:

1. **One central place** computes everything about the device and window (size classes, profile, insets, text scale, density) and exposes layout tokens. **No screen ever reads raw sizes, orientation, or defines breakpoints.**
2. **Responsiveness is automatic by default.** Page scaffolds, the router, and a small set of adaptive widgets apply safe areas, margins, max widths, scrolling, columns, and chrome (bar or rail) **without per-screen configuration**. A new screen built with the standard page widget is responsive for free.
3. **Every route is verified automatically** across a catalogue of device sizes, so regressions cannot slip in and new screens are covered without extra test code.

A previous layout prompt introduced a layout system and, apparently, only the auth screens were moved onto it. **Do not build a parallel system.** Audit what exists in `lib/app/layout/`, `lib/app/shell/`, and the screens, reuse what is sound, upgrade what is not, and migrate everything. Where this document contradicts existing code, this document wins (record it in an ADR).

Read first: `docs/architecture.md`, all ADRs, `.cursor/rules/`, `docs/layout-system.md` (if present), the navigation, theming, lifecycle, and UI-states docs, `lib/app/` (theme, router, shell, widgets, layout), and every screen under `lib/features/` including the vet portal screens and the vet map. **Follow all existing rules**: theme tokens only, localised strings, controllers owned by `State`, the shell keeps one stable widget tree, nothing resets on rotation or resize, no network from screens, reduced motion respected, the shared state components (`AsyncStateView`, `EmptyState`, `AppSnack`, `AppDialog`) where they exist.

## Ground rules

- No new dependencies. Use Flutter's built-in layout widgets.
- Layout decisions are driven by **available window size (size classes), not `Orientation`**.
- Decisions that choose a layout (profile, columns, rail versus bar) are made **only from the root `LayoutScope`**, computed from `MediaQuery.sizeOf` (full window size) and **never** from a `LayoutBuilder` inside a `Scaffold`, because that height shrinks when the keyboard opens and would flip the layout mid-typing. Leaf widgets may use `LayoutBuilder` for local column counts from *width* only.
- Every screen must work at **320 dp width, 360 dp height, text scale 2.0, with the keyboard open, with a display cutout on either side, and with a side navigation bar** (3-button navigation in landscape).
- Performance: `MediaQuery.sizeOf`/`textScalerOf`, not `MediaQuery.of`. `LayoutScope` notifies dependents **only when the profile or a token-relevant class changes**, not on every pixel of a resize drag. No blur, no heavy shadows.

## Step 0: Audit and failing tests (before changing code)

1. Write `docs/responsive-audit.md`: what exists in the layout system, which screens use it, and a table of **every route, dialog, and sheet** (farmer app, vet-request flow, GPS and photo capture, settings, vet portal, vet map) with how it behaves at: 320x568, 360x800, 412x915 portrait; 800x360, 915x412 landscape; 600x960 and 1280x800 tablet; text scale 2.0; keyboard open. Record the actual problem for each (overflow, unreachable button, content under system bars, stretched edge-to-edge text, wasted space, state loss on rotation).
2. Identify **why** non-auth screens are not adaptive (own `Scaffold`s, fixed `height`/`width`, `Row`s without `Flexible`, non-scrollable bodies, raw `MediaQuery`, no max width, bottom insets ignored, rail without labels, and so on). List the patterns found, because the architecture tests in Part F target exactly these.
3. Build the all-routes matrix test (Part F) first. It will fail broadly. Record the failures in `test/layout/known_failures.txt`. This is a **ratchet**: the list may only shrink, and it must be empty at the end.

## Part A: The central source of truth (`lib/app/layout/`)

Everything below lives in this folder and is documented in `docs/layout-system.md`. Reuse existing files where they exist.

### A1. Size classes and profile

- Width classes: `narrow` < 360 dp, `compact` 360 to 599, `medium` 600 to 839, `expanded` 840 to 1199, `large` >= 1200.
- Height classes: `short` < 480 dp, `regular` 480 to 899, `tall` >= 900.
- `LayoutProfile`: `phonePortrait` (width < 600), `phoneLandscape` (width >= 600 and height short), `tablet` (width >= 600 and height >= 480), `cramped` (width < 320 or height < 240, for narrow split-screen windows).
- Flags: `isNarrow`, `isShort`, `isLargeText` (text scale >= 1.5), `hasSideInset`, `reducedMotion`.
- All thresholds are named constants in one file (`breakpoints.dart`). No magic numbers anywhere else.

### A2. `LayoutScope` and `context.layout`

An `InheritedWidget` (or `InheritedModel` with aspects) placed **once** in `MaterialApp.builder`, below `MediaQuery`. It exposes through `context.layout`:

- `profile`, `widthClass`, `heightClass`, flags above;
- **tokens** (constants per profile, tuned visually):

| Token | narrow | phonePortrait | phoneLandscape | tablet |
|---|---|---|---|---|
| page margin | 12 | 16 | 20 | 24 to 32 |
| gutter | 8 | 12 | 12 | 16 |
| space scale (multiplier on `AppSpacing`) | 0.875 | 1.0 | 0.875 | 1.125 |
| content max width | full | full | full | 1000 |
| form max width | full | full | 640 | 640 |
| reading max width | full | full | 560 | 560 |
| min card width (grids) | 140 | 160 | 180 | 220 |
| dialog max width | full minus 24 | full minus 32 | 560 | 560 |
| sheet max width | full | full | 640 | 640 |
| top bar on tab roots | standard | standard | **none** (title is content) | standard |
| navigation chrome | bottom bar | bottom bar | rail | rail |

- `columnsFor(availableWidth, {minItemWidth})` helper that also accounts for large text (fewer columns when `isLargeText`).
- `space(int step)` (profile-aware spacing from the spacing scale), `touchTarget` (never below 48), and sizing tokens for icons, avatars, and stat tiles.
- Notification rule: dependents rebuild only when `profile`, `widthClass`, `heightClass`, or a flag changes.

### A3. Automatic safe-area and width handling

- `ContentFrame` (upgrade the existing one): applies safe-area insets on **all four sides** (left or right cutout, side navigation bar, gesture bar), the page margin, and the max width (centred), then **marks the insets as consumed** (`MediaQuery.removePadding`) so nested widgets and `Scaffold` never double-apply them. Scrollables inside it get the **bottom inset as scroll padding** automatically so the last item clears the gesture bar and FAB.
- `PageLayout` preset enum used by pages and routes instead of numbers: `standard` (lists, dashboards: content max width), `form` (form max width), `reading` (reading max width), `fullBleed` (maps, splash, photo viewer: no max width, but overlays still respect insets).

### A4. `AppPage`: the default page scaffold (upgrade the existing one)

Every screen uses `AppPage`. It takes a title, actions, a body (`slivers` or `children`), an optional FAB and sticky bar, and **a `PageLayout` preset**, and it handles automatically:
- top-bar behaviour per profile (none on tab roots in `phoneLandscape`, slim 48 dp on pushed pages when short, standard otherwise, with a correct back button);
- `ContentFrame`, scrolling (non-scrollable bodies are wrapped in a scroll view by default, with an explicit opt-out for maps and fixed canvases), pull-to-refresh and state components where the page uses them, keyboard avoidance and `ensureVisible` on focus, the FAB and `StickyActionBar` placement above the keyboard and inside insets, and snackbar offsets above the navigation chrome.

### A5. Router-level default (the "zero configuration" safety net)

All routes are built through one `buildAppPage(...)` helper (typed routes call it). It takes the screen and a `PageLayout` and wraps the result in `ContentFrame` **unless the screen already uses `AppPage`** (detected through an inherited marker). So even a screen that forgets to use `AppPage` still gets safe-area, margins, max width, and scrolling behaviour. The helper also provides the standard page transition. Routes declare **only** a preset.

### A6. Adaptive widgets (so screens declare intent, not breakpoints)

- `AdaptiveGrid`/`SliverAdaptiveGrid`: columns from **available width and `minItemWidth`** (large-text aware), fixed `mainAxisExtent` that scales with the text scale. Never aspect ratios.
- `TwoPane` (primary and secondary, flex), used automatically in `phoneLandscape` and `tablet`, stacked vertically (primary first) otherwise. Each pane scrolls independently and consumes the insets.
- `AdaptiveForm` (`AdaptiveFormGrid` plus `StickyActionBar`): one or two columns by **available width**, labels stay above fields, actions pinned.
- `ResponsiveRow`/`AdaptiveWrap`: switches between row and wrapped column by available width.
- `AdaptiveDialog`/`AdaptiveSheet` (extend the shared `AppDialog`/sheet helper): max width and max height (about 90% of the window), scrollable content, safe-area aware.
- `AdaptiveMedia` (images, photo grids, map thumbnails): constrained aspect ratios, `cacheWidth` sized to the display size, loading and error placeholders.

### A7. Shell and chrome

- Keep the **stable widget tree** for the `StatefulNavigationShell`. Only the chrome (bottom `NavigationBar` or side `NavigationRail`) changes, driven by `context.layout`. Rotating or crossing a threshold must not reset any branch (stack, scroll, form, or dialog).
- Rail: labels visible (selected item on `phoneLandscape`, all on `tablet`), distinct icons, 48 dp targets, a Today badge, **scrolls safely** when the height is short, **leading** = brand logo, **trailing** = sync status (icon-only with tooltip) and account avatar. This replaces the duplicated top bar on tab roots in landscape.
- Respect the rail-side inset when the cutout or navigation bar is on the left or right, in both landscape rotations.
- Set `debugShowCheckedModeBanner: false`.

### A8. Dev tooling (dev flavor only)

- **Layout inspector overlay** (toggle in the developer area): shows current width and height (dp), profile, classes, flags, insets, text scale, and column counts, so everyone can see the central values.
- **Window size override**: choose a preset device (see Part F catalogue) and render the app inside that window size and text scale, so designers can review small phones, tablets, and landscape without hardware.

## Part B: Migrate every screen (in this order; update the audit table as you go)

For each screen: remove its own `Scaffold`, fixed sizes, and raw `MediaQuery`; use `AppPage` with the right `PageLayout`; use the adaptive widgets. **Do not add per-screen breakpoints.** Required specifics:

- **Today:** `TwoPane` in `phoneLandscape` and `tablet`: primary = "Needs attention", secondary = "At a glance" (2x2 grid in `phoneLandscape`, 4 across on wide tablets); greeting becomes a single-line header (no hero card); stat cards are compact (about 110 dp tall or less on phones) with the icon and value on one row; bottom inset respected in both panes. At 915x412 and text scale 1.0 the greeting, the whole stats grid, and the first tasks are visible without scrolling.
- **Batches (list), Feed, Records:** list items in an `SliverAdaptiveGrid` (one column below about 720 dp of content width, two or more above); Records' sub-tabs scroll away with the content on short screens; FAB clears insets.
- **Batch detail, task detail, vaccinations list:** `reading`/`standard` preset, `Wrap` for chip rows, schedule rows wrap at text scale 2.0 and never clip; key facts first.
- **Create and edit forms (batch, feed, health, mortality, events, vet request, farm location):** `AdaptiveForm` with `form` preset, sticky actions, two columns when the width allows, scroll to the focused field with the keyboard open.
- **Vet request flow, consultation history, photo attach and grids:** adaptive grids for photos, status timeline that wraps, upload states that fit.
- **GPS capture:** the accuracy indicator and actions stay visible in short landscape (compact horizontal layout).
- **Settings, Appearance, Notifications, Sync diagnostics, More:** `form` preset (max 640, centred on large screens), tiles at least 56 dp, controls that wrap at large text.
- **Vet map and vet portal:** `fullBleed` for the map with overlay controls and the legend positioned **inside the safe area** and collapsible when short; the request list and details as `TwoPane` on `tablet` and `phoneLandscape`; filters in a sheet or chips that wrap.
- **Dialogs, sheets, snackbars, menus:** through the adaptive helpers (max width, scroll, safe area, offset above chrome).
- **Splash and auth:** confirm they use the same central system (auth must not keep a private copy of any layout logic).
- Replace any fixed `height`/`width` on containers that hold text or forms with flexible constraints.

## Part C: Rules for text, type, and density

- Do not scale font sizes with width. Use the theme's type scale. Drop one step for headings only when `isShort`.
- Text scale up to 2.0 must not overflow or hide actions: `Flexible`, `Wrap`, `maxLines` with ellipsis only where the full text is available elsewhere. In `isLargeText`, forms use one column and grids use fewer columns.
- Reading text lines cap at the `reading` max width on large screens.
- Touch targets stay at least 48 x 48 dp in every profile, including the denser landscape tokens.

## Part D: Behaviour and state

- Rotating or resizing at any moment (mid-form, mid-dialog, mid-stack, mid-animation) changes only the layout. No provider disposes, no router rebuild, no splash replay, no lost text, focus, or scroll.
- Fold/unfold and split-screen resizes behave the same way.
- `LayoutScope` and the shell must not cause a rebuild storm during a continuous resize drag within one class.

## Part E: Enforcement (architecture tests, `test/architecture/layout_rules_test.dart`)

In `lib/features/**` (excluding `lib/app/layout/**`), fail on: `MediaQuery.of(context).size`, `MediaQuery.of(context).orientation`, `OrientationBuilder`, `Orientation.landscape`, `MediaQuery.sizeOf` (layout reads go through `context.layout`), `Scaffold(` (use `AppPage`), numeric `width:`/`height:` literals above 160 on containers that are not decorative, `Expanded`/`Flexible` outside a `Row`/`Column`/`Flex` (no-ops that hide intent), and `SizedBox(height: <literal >= 200>)`. Provide a reviewed allow-list with a written reason per entry (for example fixed-size canvases and the map). Also forbid `SCREEN`-size constants like `360`, `600`, `840` outside `breakpoints.dart`. Every `*_screen.dart` must reference `AppPage` or an `AuthShell`-style shared shell. Update `.cursor/rules/layout.mdc` with these rules.

## Part F: Tests (all required)

**Device catalogue** (`test/layout/device_profiles.dart`, reused by the dev window-size override):

| Name | Size (dp) |
|---|---|
| Small phone | 320x568 |
| Older phone | 360x640 |
| Standard phone | 360x800, 393x852, 412x915 |
| Large phone | 480x1000 |
| Foldable (unfolded) | 673x841 |
| Small tablet | 600x960 |
| Tablet | 800x1280 |
| Landscape phone | 640x360, 800x360, 915x412 |
| Landscape tablet | 1280x800, 1024x768 |
| Split-screen slivers | 320x400, 411x300 |

For each size also run text scale 1.0, 1.3, and 2.0, light and dark, with insets: none; left cutout (about 48 dp); right cutout; bottom gesture bar (about 24 dp); side navigation bar (about 48 dp on the right in landscape); keyboard open (about 300 dp view inset).

**All-routes matrix (the central test):** `test/layout/all_routes_matrix_test.dart` enumerates **every registered typed route** (derive the list from the router's route registry, so new routes are included automatically) with a sample param and a fake data scenario from a `RouteSamples` registry. **The test fails if a route has no sample.** For every route, size, text scale, theme, and inset combination assert: no exceptions (`tester.takeException()` is null, so no overflow); no horizontal scrolling; the primary action is hit-testable (after `ensureVisible`); **no interactive widget's rect intersects the unsafe inset areas**; content width never exceeds the preset's max width; minimum touch targets (`androidTapTargetGuideline`); labelled targets; text contrast; and the shell shows a bar on `phonePortrait` and a rail otherwise. Use `known_failures.txt` as the ratchet during the migration.

**Goldens** (light and dark, portrait and landscape, small phone and tablet) for: Today, Batches list, batch detail, task detail, a form, Settings, Notifications, the vet request flow, GPS capture, the vet map and portal inbox, a dialog, and a bottom sheet.

**Behavioural tests:** rotate mid-stack, mid-form (typed text and focus preserved), and mid-dialog and assert nothing resets; crossing the rail threshold keeps every branch's stack and scroll; keyboard open does not change the profile or the chrome; a resize drag within one class triggers no rebuilds of screens (build counters); text scale 2.0 switches forms to one column; `columnsFor` unit tests (widths, large text); token table tests; `LayoutScope` notification tests (only on class changes).

**Zero-config proof:** add a dev-only `LayoutSandbox` screen built with only `AppPage` and a preset (no extra layout code), include it in the route samples, and show that it passes the full matrix. This demonstrates that a new screen is responsive for free.

**Accessibility:** tap-target, labelled-target, and contrast guidelines in the matrix; TalkBack order survives layout changes.

## Manual QA (write to `docs/responsive-qa.md`; run on real phones)

A small old phone and a large phone; both landscape rotations on a notched phone; **gesture and 3-button navigation** (in landscape the 3-button bar sits on a side); largest font size and largest display size; split-screen at several sizes; a tablet or foldable if available; keyboard open on every form in landscape; TalkBack through the rail and a form; dark and light; dev, staging, and prod builds. Use the dev Layout inspector to confirm the central values on each device.

## Docs

Update `docs/layout-system.md`: size classes, profile table, token table, the three layers (central `LayoutScope`, automatic `AppPage`/router wrapper, adaptive widgets), how to build a new screen in five lines, the do/don't list, and the "never decide layout from a `LayoutBuilder` inside a `Scaffold`" rule with the keyboard example. Add ADRs: (1) a single `LayoutScope` as the only source of layout decisions, (2) automatic responsiveness through `AppPage` and a router-level `ContentFrame` safety net, (3) presets (`PageLayout`) instead of per-screen numbers, (4) profile computed from full window size, not constrained height, (5) the all-routes matrix with a ratchet and a mandatory route sample, (6) architecture rules banning raw sizes and `Scaffold`s in features. Update `docs/responsive-audit.md` with before and after for every route.

## Acceptance criteria

1. `flutter analyze` and `flutter test` pass, including the all-routes matrix (with `known_failures.txt` **empty**), goldens, behavioural tests, and architecture tests.
2. On real phones, in portrait, **both landscape rotations**, split-screen, small, and large sizes, **no screen overflows, wastes obvious space, hides a control, or sits under the gesture bar, navigation bar, or cutout.**
3. At 915x412 and text scale 1.0, Today shows the header, the whole stats grid, and the first tasks without scrolling. The rail shows labels and never overflows. On a tablet, content is centred with sensible margins and multi-column grids, not stretched edge to edge.
4. Rotating or resizing at any moment changes only the layout. No state, text, focus, or scroll is lost.
5. No screen contains a breakpoint, an orientation check, a raw `MediaQuery` size read, or its own `Scaffold`. All of that lives in `lib/app/layout/`.
6. The `LayoutSandbox` screen, built with only `AppPage` and a preset, passes the full device matrix, and adding a new route without a route sample fails CI.
7. The dev Layout inspector and window-size override work and show the central values.

## Out of scope

Side-by-side list and detail (master-detail) layouts beyond `TwoPane` where specified, foldable hinge awareness, redesigning the brand or theme, new features, and iOS or web.

## Working style

Commit after each step: (0) audit doc, the all-routes matrix test, and `known_failures.txt`; (1) breakpoints, `LayoutScope`, tokens, and `context.layout`; (2) `ContentFrame` with inset consumption, `PageLayout` presets, and `AppPage`; (3) router-level `buildAppPage` safety net; (4) adaptive widgets (`AdaptiveGrid`, `TwoPane`, `AdaptiveForm`, adaptive dialog and sheet, `AdaptiveMedia`); (5) shell and rail chrome; (6) migrate screens in this order: Today, Batches, Feed, Records, batch and task detail, forms, vet request flow, GPS and photos, Settings and Notifications, vet map and portal, dialogs and sheets, splash and auth check (shrink `known_failures.txt` with each commit); (7) dev layout inspector and window-size override, plus the `LayoutSandbox`; (8) architecture tests and the cursor rule; (9) goldens and behavioural tests; (10) docs and ADRs. If something is ambiguous, choose the conservative option, record it in an ADR, and continue. End with the before/after table per route, assumptions, and anything you could not verify without a physical device.