# ADR 010: Router created once with refreshListenable

## Status
Accepted

## Decision
`appRouterProvider` watches only `routerRefreshProvider`. Auth changes notify `RouterRefresh` instead of recreating `GoRouter`.

## Consequences
- Navigation stacks survive auth snapshot reloads.
- Redirect logic reads `hasAuthSnapshotProvider` via `ref.read` inside `redirect`.
