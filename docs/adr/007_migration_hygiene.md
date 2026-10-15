# ADR-007: Migration hygiene — one concern per file, no edits to applied migrations

Status: Accepted
Date: 2026-10-15

## Context

The migration that triggered this review (`0017_feed_module.sql`) combined three unrelated concerns in a single file: feed schema changes, a full rewrite of `sync_push`, and a new `list_available_vets` RPC. This made the change hard to review, difficult to roll back selectively, and — because it also redefined `sync_push` — potentially destructive if applied on top of a production database that already had an earlier correct version of the function. Additionally, several bugs were found in the pushed migration that would have required either editing the applied file (dangerous) or writing corrective migrations. There was no consistent convention for rollback notes or header comments.

## Decision

Each migration file addresses exactly one concern. A concern is defined as a single table change, a single function definition, or a tightly related group of CHECK constraints on the same table. Applied migrations are never edited; all corrections are made in new, numbered migration files. Each file must include a header comment stating the reason for the migration and rollback notes describing how to reverse the change if needed. The corrective approach adopted here (0018 for feed schema, 0019 for `sync_push`, 0020 for the vet RPC) is the template for future work.

## Consequences

- Git history is clean and bisectable: a bug introduced in a migration is traceable to a single file and a single concern.
- Rollback is always feasible by running the rollback steps from the header comment.
- The overhead of multiple files per fix is acceptable — migration files are cheap to create and the review benefit outweighs the cost.
- Reviewers can approve each concern independently without understanding the full function rewrite.
