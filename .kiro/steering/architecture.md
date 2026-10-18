---
inclusion: always
---

# CucoCare architecture rules

1. Widgets never touch Drift, Supabase, or HTTP. They talk to Riverpod providers that call use-cases/repositories.
2. Repositories read and write **only Drift**. Writes to synced tables also insert an **outbox** row in the **same transaction**.
3. Domain code is pure Dart (no Flutter, Drift, or Supabase imports) and has unit tests.
4. IDs are client-generated UUIDs (prefer v7). Never rely on server-generated IDs.
5. **Store dates, never ages.** Compute batch age at read time from `acquired_on` and `age_at_acquisition_days`, using an injected `Clock`.
6. Append-only tables (`feed_transactions`, `mortality_records`, `health_records`, `farm_events`) are never updated in place. Feed stock is **derived** from transactions.
7. Deletes are soft (`deleted_at`). Sync propagates tombstones.
8. Use `Result<T>`/typed failures at boundaries. No swallowed exceptions. Log with the logger.
9. No secrets in the repo or in the app bundle beyond the Supabase URL and anon key.
10. Small, reviewable commits. Ask before adding dependencies or deviating from the scaffold.
