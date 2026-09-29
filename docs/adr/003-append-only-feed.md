# ADR 003: Append-only feed stock

## Status

Accepted

## Context

The concept paper modeled mutable `FEED.quantity`. That complicates sync and audit trails.

## Decision

Model feed as append-only `feed_transactions`; on-hand stock is derived at read time. No in-place quantity updates.

## Consequences

- Extra aggregation when displaying stock levels.
- Cleaner sync and history for usage and purchases.
