import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'local_database_identity.dart';

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
import 'tables/vet_assistance_requests.dart';

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
    VetAssistanceRequests,
  ],
  daos: [OutboxDao, SyncDao, SyncMetaDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.forAccount(String? userId, [QueryExecutor? executor])
      : super(executor ?? _openConnectionForAccount(userId));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

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
          if (from < 4) {
            await m.addColumn(batches, batches.productionType);
            await m.addColumn(batches, batches.programmeContentHash);
            await m.addColumn(vaccinationTasks, vaccinationTasks.occurrence);
            await m.addColumn(vaccinationTasks, vaccinationTasks.enabled);
            await m.addColumn(vaccinationTasks, vaccinationTasks.doneBy);
            await m.addColumn(vaccinationTasks, vaccinationTasks.stepSnapshot);
            await m.addColumn(
              vaccinationTasks,
              vaccinationTasks.programmeContentHash,
            );
            await m.addColumn(vaccinationTasks, vaccinationTasks.shiftedFrom);
          }
          if (from < 5) {
            await m.addColumn(authSnapshot, authSnapshot.appRole);
          }
          if (from < 6) {
            await m.addColumn(healthRecords, healthRecords.affectedBirdCount);
            await m.addColumn(healthRecords, healthRecords.symptomsJson);
            await m.addColumn(healthRecords, healthRecords.recordKind);
            await m.addColumn(farms, farms.latitude);
            await m.addColumn(farms, farms.longitude);
            await m.addColumn(farms, farms.locationAccuracyM);
            await m.addColumn(farms, farms.locationCapturedAt);
            await m.createTable(vetAssistanceRequests);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return _openConnectionForAccount(null);
  }

  static QueryExecutor _openConnectionForAccount(String? userId) {
    return driftDatabase(name: localDatabaseNameForAccount(userId));
  }
}
