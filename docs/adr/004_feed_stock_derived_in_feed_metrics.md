# ADR-004: Feed stock is derived exclusively in FeedMetrics.compute

Status: Accepted
Date: 2026-10-15

## Context

Before this change, stock quantities were computed in at least three places: the feed repository, the report screen, and the report preview widget. Each had a slightly different formula — some did not account for adjustments, some did not handle the `wastage` kind, and none had a defined behaviour when the derived stock was negative (which can happen when offline writes on two devices create an inconsistency before sync resolves). The inconsistency meant the Stock tab, the Report tab, and the exported CSV could show different numbers for the same item.

## Decision

`FeedMetrics.compute` is the sole source of truth for all stock calculations. It accepts a `FeedItem` and a list of non-deleted `FeedTransaction` objects and returns a `FeedMetrics` instance containing: `currentQuantity` (clamped to zero for display), `rawQuantity` (may be negative, used to set `isInconsistent`), `totalPurchased`, `totalConsumed`, `totalWasted`, `totalAdjustment` (signed sum), and `totalCost`. Every consumer — the stock provider, the detail screen, the report generator — calls this factory. An architecture test (`test/architecture/feed_rules_test.dart`) scans the codebase and fails if stock arithmetic appears outside `FeedMetrics` or `FeedRepository`.

## Consequences

- One place to change if the formula evolves (e.g., adding a `transfer` kind).
- The architecture test provides a compile-time-equivalent guard against regressions.
- Display never shows negative stock; `isInconsistent` surfaces a calm "please review" message.
- `FeedStock` (the previous class) is removed; callers are updated to `FeedMetrics`.
