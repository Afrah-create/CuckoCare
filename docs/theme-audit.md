# Theme audit (initial migration)

| File | Issue | Resolution |
|------|--------|------------|
| `sync_status_badge.dart` | `Colors.green/orange` | `context.colors.sync*` + `StatusChip` |
| `app_logo.dart` | `Theme.brightness` for tint | `context.colors.logoTint` |
| `splash_*` | `brandTokens` + brightness | `context.colors.splashBackground` / `logoTint` |
| `local_reminder_scheduler.dart` | `Color(0xFF622347)` | `BrandPalette.brandInk` |
| `app.dart` | inline `buildAppTheme` | `AppTheme` + `themeModeProvider` |

Remaining feature code should use `context.colors`, `context.scheme`, and `context.text` only.
