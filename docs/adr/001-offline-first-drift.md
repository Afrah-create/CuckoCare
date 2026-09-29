# ADR 001: Offline-first with Drift as source of truth

## Status

Accepted

## Context

Farmers have unreliable connectivity and limited data budgets.

## Decision

All UI reads/writes use local SQLite (Drift). Network is used only for sync, auth refresh, and server-mediated payments/SMS.

## Consequences

- Requires outbox-based delta sync and robust session caching.
- Simpler UI code paths and predictable offline behavior.
