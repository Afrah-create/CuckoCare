import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/outbox_dao.dart';
import 'daos/sync_dao.dart';
import 'daos/sync_meta_dao.dart';
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
import 'tables/sync_events.dart';
import 'tables/sync_lock.dart';
import 'tables/sync_meta.dart';
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
    SyncMeta,
    SyncEvents,
    SyncLock,
    AuthSnapshot,
  ],
  daos: [OutboxDao, SyncDao, SyncMetaDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(outbox, outbox.state);
            await m.addColumn(outbox, outbox.leaseUntil);
            await m.addColumn(outbox, outbox.retryable);
            await m.addColumn(outbox, outbox.errorCode);
            await m.addColumn(outbox, outbox.nextAttemptAt);
            await m.createTable(syncMeta);
            await m.createTable(syncEvents);
            await m.createTable(syncLock);
          }
          if (from < 3) {
            await m.addColumn(farms, farms.district);
            await m.addColumn(farms, farms.village);
            await m.addColumn(farms, farms.phone);
            await m.addColumn(farms, farms.altPhone);
            await m.addColumn(farms, farms.profileCompletedAt);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'cucocare_v1');
  }
}
