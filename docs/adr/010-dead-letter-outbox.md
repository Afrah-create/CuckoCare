# ADR 010: Outbox dead-letter policy

## Status

Accepted

## Decision

Ops rejected with `retryable: false` move to `failed` (dead letter) and do not block the queue. Users may retry or discard from Settings → Sync diagnostics.

## Consequences

- Local record keeping continues even when one op is permanently invalid.
- Support can inspect failed ops and error codes on device.
