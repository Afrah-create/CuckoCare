# ADR 019: Theme preference is device-local

## Status

Accepted

## Decision

Theme mode is stored in `shared_preferences` (`theme_mode`). It is **not** synced to Supabase and survives sign-out and full resync.
