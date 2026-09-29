import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/outbox_dao.dart';
import 'daos/sync_dao.dart';
import 'tables/auth_snapshot.dart';
import 'tables/batches.dart';
import 'tables/entitlements.dart';
import 'tables/farm_events.dart';
import 'tables/farm_members.dart';
import 'tables/farms.dart';
import 'tables/feed_items.dart';
import 'tables/feed_transactions.dart';
import 'tables/health_records.dart';
import 'tables/mortality_records.dart';
import 'tables/outbox.dart';
import 'tables/programme_steps.dart';
import 'tables/programmes.dart';
import 'tables/sync_cursors.dart';
import 'tables/vaccination_tasks.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Farms,
    FarmMembers,
    Batches,
    Programmes,
    ProgrammeSteps,
    VaccinationTasks,
    FeedItems,
    FeedTransactions,
    HealthRecords,
    MortalityRecords,
    FarmEvents,
    Entitlements,
    Outbox,
    SyncCursors,
    AuthSnapshot,
  ],
  daos: [OutboxDao, SyncDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Future migrations: use drift_dev schema export + migration tests.
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'cucocare_v1');
  }
}
