# ADR 008: Row-level LWW and monotonic vaccination status

## Status

Accepted

## Decision

Mutable rows use last-write-wins by arrival at the server (via commit-ordered version). `vaccination_tasks.status` uses rank: pending < assumed_done < skipped < done; lower ranks never overwrite higher.

## Known limitation

Concurrent edits to **different fields** of the same row on two devices: one edit is lost (no field-level merge).
