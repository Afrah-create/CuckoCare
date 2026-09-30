# ADR 007: StatefulShellRoute with a stack per tab

## Status
Accepted

## Context
Bottom navigation used a single `IndexedStack` without go_router branch navigators. Back closed the app and tab stacks were not independent.

## Decision
Use `StatefulShellRoute.indexedStack` with five branches (Today, Batches, Feed, Records, More). Each branch keeps its own navigator stack and restoration scope.

## Consequences
- Tab switches preserve drill-down state.
- Shell back handling can pop branch stacks before changing tabs.
