# ADR 004: Server-side MakyPay and MakyReach

## Status

Accepted

## Context

Payment and SMS providers must not expose API secrets in the Android app.

## Decision

Client calls Supabase Edge Functions with the user JWT. Webhooks and entitlement grants run server-side with service role.

## Consequences

- Requires Edge Function deployment and provider documentation.
- Entitlements sync down to Drift for offline premium checks within `valid_until`.
