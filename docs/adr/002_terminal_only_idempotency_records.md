# ADR-002: Only terminal outcomes are stored in sync_ops_applied

Status: Accepted
Date: 2026-10-15

## Context

`sync_ops_applied` was designed to make `sync_push` idempotent — replaying the same `op_id` returns the original result without re-executing the operation. The problem was that transient failures (specifically FK violations, `sqlstate = '23503'`) were also stored in `sync_ops_applied` with `retryable = true`. When the client retried after the parent row had been synced, the idempotency check found the stored entry and returned a `duplicate` response, permanently blocking the operation. The FK dependency would never resolve.

## Decision

Only terminal outcomes are written to `sync_ops_applied`: a successful apply (`applied`) and a non-retryable rejection (e.g., `forbidden`, `not_found`). Retryable failures — most importantly FK violations — are returned to the client without being stored. On a subsequent retry the full upsert logic runs again; if the parent row now exists the operation succeeds and is stored as `applied`. Non-retryable rejections are stored so that replaying a bad op does not repeatedly run forbidden code paths.

## Consequences

- Clients can retry transient failures correctly; the op eventually resolves once the dependency is satisfied.
- Idempotency is still guaranteed for the two cases that matter: a successful apply is not applied twice; a permanently rejected op returns the same rejection on replay.
- The tradeoff is a small window between the first retryable failure and a successful retry where the server does redundant FK checks — acceptable given typical sync batch sizes.
