---
inclusion: fileMatch
fileMatchPattern: ['lib/**/*.dart']
---

# Theme

- Only `lib/app/app.dart` consumes `themeModeProvider`.
- Widgets use `context.colors`, `context.scheme`, and `context.text` — no brightness branching.
- No `Color(0x…)` or `Colors.*` outside `lib/app/theme/`.
- Status colours use `StatusChip` (icon + label).
