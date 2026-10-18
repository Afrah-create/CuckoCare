---
inclusion: fileMatch
fileMatchPattern: ['lib/**/*.dart']
---

# Lifecycle

- Only `AppLifecycleService` may use `AppLifecycleListener`.
- Only `bootstrap.dart` may call `SystemChrome.setPreferredOrientations`.
- `AppShell` keeps `StatefulNavigationShell` in a fixed `Expanded` slot; use `Offstage` for rail vs bar.
- Calendar "today" uses `kampalaTodayProvider`, not `DateTime.now()` in widgets.
