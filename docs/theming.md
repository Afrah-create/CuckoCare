# Theming

## Single switch

Only `MaterialApp` in `lib/app/app.dart` reads `themeModeProvider`. Widgets use:

- `context.colors` — semantic `AppColors`
- `context.scheme` — Material `ColorScheme`
- `context.text` — `TextTheme`

No `Brightness` checks in feature widgets.

## Tokens

| File | Role |
|------|------|
| `brand_palette.dart` | Raw hex — **rebrand here** |
| `app_colors.dart` | Semantic tokens + `lerp` |
| `component_themes.dart` | Shared `ThemeData` pieces |
| `app_theme.dart` | Cached `AppTheme.light` / `.dark` |

## Persistence

`SharedPrefsThemePreferenceRepository` stores `theme_mode` (`system` | `light` | `dark`). Loaded in `main()` before `runApp` via `initialThemeModeProvider` override. Not synced to Supabase; survives sign-out.

## Native splash limitation

Native splash follows **system** theme only; a brief mismatch is possible if app preference differs until the first Flutter frame (ADR 018).

## Adding a token

1. Add field to `AppColors` with `copyWith` + `lerp`.
2. Set light/dark values in `AppColors.light` / `.dark`.
3. Use via `context.colors` in UI.

## Do / don't

- Do use `StatusChip` for coloured status (icon + label).
- Don't use `Color(0x…)`, `Colors.*`, or `Theme.of(context).brightness` in features.
