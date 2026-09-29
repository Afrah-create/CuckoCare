# ADR 007: Config-driven sync tables

## Status

Accepted

## Decision

`sync_table_config` drives allowed columns and table kind (`mutable`, `append_only`, `reference`) for `sync_push` / `sync_pull`. Adding a table is a config row plus DDL.

## Consequences

- Less duplicated PL/pgSQL; allow-lists prevent clients from writing `server_version` or mutating `farm_id` on existing rows.
