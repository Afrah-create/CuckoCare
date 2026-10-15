# ADR-005: Server-controlled vet request state transitions; pending_sync removed as a server status

Status: Accepted
Date: 2026-10-15

## Context

Farmers could push any status value for a `vet_assistance_request`, including `accepted`, `in_progress`, and `completed` — statuses that must only be set by the vet or the server. A farmer could also revert a vet-controlled status back to `submitted` or `cancelled` after the vet had already accepted. Additionally, the Dart sync layer used `pending_sync` as a local-only sync state (meaning "written locally, not yet pushed"), and this string was leaking into the `status` column of rows being pushed to the server, polluting the server-side state machine.

## Decision

Farmer-writable statuses are limited to `draft`, `submitted`, and `cancelled` (with the restriction that `cancelled` is only accepted before the vet has accepted the request — i.e., the current server status is not in `('accepted', 'in_progress', 'completed')`). Server-controlled statuses (`received`, `accepted`, `declined`, `in_progress`, `completed`) are rejected with a non-retryable `forbidden` if a farmer attempts to push them. Any row arriving with `status = 'pending_sync'` is normalised to `submitted` by `sync_push` before the upsert. This normalisation is documented as a one-time transition; existing rows with `pending_sync` on the server require a clean-up script (see open questions in `docs/feed-module-review.md`).

## Consequences

- Vet workflow integrity is enforced at the server boundary — a compromised or buggy client cannot skip states.
- `pending_sync` is no longer a server status; the domain model is cleaner.
- Existing rows on the production server with `status = 'pending_sync'` are not automatically fixed — a clean-up script must be run (open question).
- The Dart enum for vet request status should not include `pending_sync`; any local-only sync marker must live in a separate field or the outbox metadata.
