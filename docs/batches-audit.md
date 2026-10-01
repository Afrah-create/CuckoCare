# Batches and schedule audit (Step 0)

## Existing pieces

| Area | Location | Decision |
|------|----------|----------|
| Batch CRUD (minimal) | `lib/features/batches/data/batch_repository.dart` | **Extend** — planner-backed create with tasks in one transaction |
| Batch UI stubs | `batches_list_screen`, `batch_new_screen`, `batch_detail_screen` | **Replace/wire** — connect to real data and create wizard |
| Drift `batches` / `vaccination_tasks` | `lib/data_platform/db/tables/` | **Extend** — add occurrence, enabled, snapshots, hash (schema v4+) |
| Legacy `programmes` / `programme_steps` + `SeedProgrammeLoader` | `lib/features/vaccination/data/` | **Superseded** — loader no-ops for unified JSON; tables kept unused in v1 |
| Old domain | `materialise_vaccination_tasks.dart`, `task_scheduling.dart` | **Superseded** by `lib/features/batches/domain/batch_planner.dart` |
| Sync | `batch_synced_table`, `vaccination_task_synced_table`, sync apply | **Update** when schema columns land |
| Today metrics | `today_screen.dart` `_MetricGrid` placeholders | **Wire** to batch/task watch providers |
| Active farm | `primaryFarmProvider` | **Keep** — create-batch uses primary farm or inline farm name |
| Entitlements | `entitlements` table | **Keep** — `BatchCreationPolicy` stub later |

## Startup fix

Unified schedule JSON uses `schema_version` + `programs.*`. The old loader expected `programmes[]` and could throw during bootstrap; it now skips when the new shape is detected. Schedule content lives in `assets/seed/uganda_poultry_vaccination_schedule.json` (synced from `docs/schedule.json`).

## Next implementation steps

See `docs/logic.md` commit order: schema migration `0003_batches_schedule.sql`, repository use-cases, create-batch wizard, Today wiring, guardrails, tests, ADRs.
