# ADR 014: Splash intro policy

## Status
Accepted

## Decision
Full intro once per app version (`SharedPreferences`); quick intro thereafter; reduced motion uses static fade only. Navigation waits for bootstrap + intro via `splashGateReadyProvider`.

## Consequences
Returning users are not delayed beyond the quick intro when bootstrap is ready.
