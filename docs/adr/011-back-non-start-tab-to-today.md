# ADR 011: Back on non-start tab returns to Today

## Status
Accepted

## Decision
When the active branch stack cannot pop, Android back on tabs other than Today calls `goBranch(0)`. Back on Today calls `SystemNavigator.pop()`.

## Consequences
- Predictable exit behaviour without double-tap-to-exit.
- Users return to the primary dashboard before leaving the app.
