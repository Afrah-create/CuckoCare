# ADR 008: Detail screens hide the bottom bar

## Status
Accepted

## Decision
Drill-down and create/edit routes set `$parentNavigatorKey` to `rootNavigatorKey` so they render on the root navigator (WhatsApp-style).

## Consequences
- Full-screen details and forms.
- `pop` returns to the tab root list underneath.
