# ADR-003: Canonical feed transaction kinds and signed adjustment semantics

Status: Accepted
Date: 2026-10-15

## Context

The Dart domain model `FeedTransactionKind` enum used `consumption` and `wastage` as its canonical names. The Postgres CHECK constraint added in migration 0002 allowed `('purchase', 'usage', 'adjustment')` — `usage` instead of `consumption`, and no `wastage`. Migration 0017 broadened the constraint to include `consumption`, `wastage`, and `usage` simultaneously, leaving `usage` as a valid synonym. This ambiguity made stock derivation unreliable: a row with `kind = 'usage'` might be treated as an unknown kind by a `switch` without a default, silently returning zero contribution to stock. Additionally, `adjustment` quantities were constrained to `quantity > 0`, preventing downward stock corrections without recording a negative number.

## Decision

`consumption` is the canonical kind for feed consumed by birds, matching the Dart enum. `wastage` is the canonical kind for spoilt or discarded feed. `usage` is removed: migration 0018 renames all existing `kind = 'usage'` rows to `consumption` and drops `usage` from the CHECK constraint. The canonical set is `('purchase', 'consumption', 'wastage', 'adjustment')`. The `adjustment` quantity constraint is changed from `quantity > 0` to `quantity <> 0`, allowing negative values. A positive adjustment corrects stock upward; a negative adjustment corrects it downward. `FeedMetrics.compute` treats the adjustment quantity as already signed and adds it directly to the running total.

## Consequences

- The Dart enum is now the single source of truth for kind names; no divergence between Dart and Postgres.
- Existing `usage` rows are migrated — no data loss.
- Negative adjustments are now correctly representable; the UI `RecordFeedTransactionSheet` exposes a direction toggle for the adjustment kind.
- Any code that hardcodes the string `'usage'` will produce a rejected row at the DB level after migration 0018.
