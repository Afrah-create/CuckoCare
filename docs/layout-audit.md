# Layout audit (in progress)

Evidence from `test/layout/login_landscape_test.dart` and manual review. Full matrix per `docs/branding.md` Step 7 is not complete yet.

| Screen | Before | After (this pass) |
| --- | --- | --- |
| Login | Orientation-based `Responsive`, scroll-only column | `AuthScaffold`, size-class two-pane, keyboard-safe scroll |
| Today | Hero greeting first; ad hoc wide row; no bottom inset | Needs attention first; compact greeting; `TwoPane` in landscape; stat cards capped; scroll bottom inset |
| App shell | Rail without labels; egg batch icon; duplicated top bar in landscape | Rail labels (selected/all); batch grid icons; no top bar on tab roots in landscape; rail leading/trailing chrome |
| Demo mode | Router sent loading auth to `/splash` while on login → navigation race | Stay on `/auth/*` while auth loads; await snapshot before navigating to Today |

Remaining: migrate other feature screens to `AppPage` / `ContentFrame`, full layout matrix tests, goldens, and ADRs listed in `docs/branding.md`.
