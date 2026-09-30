# CucoCare branding

## Source artwork

- **Source (not in APK):** `design/brand/source/chicken.jpeg`
- **Regenerate:** `dart run tool/generate_brand_assets.dart`
- **Runtime masks:** `assets/brand/` (declared in `pubspec.yaml`)

## Colour tokens

Defined in `BrandTokens` (`lib/app/theme/brand_tokens.dart`):

| Token | Use |
|-------|-----|
| `brandInk` | Logo tint (light mode) |
| `brandCream` | Splash, launcher background, logo tint (dark) |
| `splashBackgroundLight` / `splashBackgroundDark` | Native splash + Flutter splash |
| `adaptiveBackground*` | Launcher adaptive background per flavor |

Native splash colours must match `flutter_native_splash.yaml` (see `test/brand/splash_colour_parity_test.dart`).

## Adaptive icon safe zone

Launcher foreground is centred with artwork inside the **central ~60%** of the 1024×1024 canvas (Android safe zone ≈ 66 dp of 108 dp).

## Generated vs hand-maintained

| Generated | Hand-maintained |
|-----------|-----------------|
| `assets/brand/**` | `lib/app/theme/brand_tokens.dart` |
| `design/brand/out/**` | `flutter_native_splash.yaml` |
| `android/.../ic_stat_hen.png` | Splash choreography (`splash_timing.dart`) |
| Mipmap icons (via flutter_launcher_icons) | `AppLogo`, `SplashMark` |

## Launcher icons

```bash
dart run flutter_launcher_icons -f flutter_launcher_icons-prod.yaml
# Copy prod output to flavor folders as needed:
dart run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml
dart run flutter_launcher_icons -f flutter_launcher_icons-staging.yaml
```

Play Store: `design/brand/out/play_store_icon_512.png`

## Native splash

```bash
dart run flutter_native_splash:create
```

Plain **brand background only** on native splash; Android 12+ uses transparent `splash_transparent.png` to hide the system icon. Flutter `/splash` continues the same background then animates the mark.

## Splash timing

- **First launch (per app version):** ~1.5 s full intro
- **Later cold starts:** ~0.7 s quick intro
- **Reduced motion:** ~250 ms static fade
- Navigate when **intro done ∧ bootstrap ready** (`splashGateReadyProvider`)

Dev: **More → Splash preview** (dev flavor).

## Manual QA checklist

- [ ] Cold start Android 8 / 11 / 12 / 13+ light & dark
- [ ] No flash between native splash and Flutter splash background
- [ ] Themed icon Android 13+
- [ ] Launcher masks: circle, squircle, square
- [ ] Notification status bar: white hen (`ic_stat_hen`), not grey square
- [ ] Dev / staging / prod icons side by side
- [ ] Remove animations: no motion on splash
- [ ] Low-end device: intro ≤2 dropped frames

## Assumptions

- Egg/hen split uses a horizontal cut + three columns; a vector source would improve wing detail.
- Flavor launcher icons may require running `flutter_launcher_icons` per flavor yaml and syncing into `android/app/src/<flavor>/res`.
