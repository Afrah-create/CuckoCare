# Lifecycle diagnosis (landscape / rotation)

Evidence from code review and tests (device logcat on SM G991U showed surface/GPU noise on resume, not Dart assertion failures after splash navigation fixes).

| Suspect | Verdict | Evidence |
|---------|---------|----------|
| **(a) Router recreated** | Not primary | `appRouterProvider` uses `ref.keepAlive()` and `routerRefreshProvider`; navigation tests assert identical `GoRouter` after theme/auth invalidation. |
| **(b) Adaptive shell swap** | **Confirmed** | `AppShell` previously inserted/removed `NavigationRail` in a `Row`, shifting the `StatefulNavigationShell` slot when crossing 600 dp (landscape phones). Fixed: `Offstage` + fixed-width rail slot; shell always `Expanded` child #2. |
| **(c) Splash replay** | Mitigated | Intro in `SplashController` with `ref.keepAlive()`; navigation deferred post-frame; no Hero on splash→home. |
| **(d) autoDispose providers** | Low risk | App-scoped providers are standard `Provider`, not autoDispose. |
| **(e) Overflow in landscape** | **Partial** | Login used a fixed header `Column`; reflowed to full-page `SingleChildScrollView` + compact header under 520 dp height. Today uses `CustomScrollView`. |
| **(f) Stale MediaQuery in initState** | Not found in shell | Shell reads `MediaQuery.sizeOf` in `build` only. |
| **(g) Duplicate GlobalKeys** | Mitigated | Splash navigation + Hero overlap fixes; stable shell keys. |
| **(h) Bootstrap in widgets** | Not cause | `bootstrap()` runs from `main.dart` once per process. |
| **(i) Manifest configChanges** | OK | `AndroidManifest.xml` lists required `configChanges`; no locked orientation; `adjustResize`; `singleTop`. |

Regression: `test/lifecycle/shell_adaptive_test.dart`, `test/navigation/router_stability_test.dart`.
