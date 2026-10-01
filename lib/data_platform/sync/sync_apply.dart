import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'remote_sync_api.dart';
import 'synced_table.dart';
import '../../features/batches/data/batch_synced_table.dart';
import '../../features/vaccination/data/vaccination_task_synced_table.dart';

int taskStatusRank(String status) => switch (status) {
      'pending' => 0,
      'assumed_done' => 1,
      'skipped' => 2,
      'done' => 3,
      _ => -1,
    };

/// Applies server pull rows into Drift (offline-first merge rules).
class SyncApply {
  SyncApply(this._db);

  final AppDatabase _db;
  final _batches = BatchSyncedTable();
  final _tasks = VaccinationTaskSyncedTable();

  Future<void> applyPullPage(List<SyncPullRow> rows) async {
    await _db.customStatement('PRAGMA defer_foreign_keys = ON');
    try {
      for (final remote in rows) {
        await _applyOne(remote);
      }
    } finally {
      await _db.customStatement('PRAGMA defer_foreign_keys = OFF');
    }
  }

  Future<void> _applyOne(SyncPullRow remote) async {
    final table = remote.table;
    final mapper = _mapperFor(table);
    if (mapper == null) {
      return;
    }

    final rowId = remote.row['id'] as String;
    final localPending = await (_db.select(_db.outbox)
          ..where(
            (o) =>
                o.targetTable.equals(table) &
                o.rowId.equals(rowId) &
                (o.state.equals('pending') | o.state.equals('in_flight')),
          ))
        .getSingleOrNull();
    if (localPending != null) {
      return;
    }

    await _applyRow(mapper, remote);
  }

  SyncedTable<dynamic>? _mapperFor(String table) => switch (table) {
        'batches' => _batches,
        'vaccination_tasks' => _tasks,
        _ => null,
      };

  /// Server wins only when [serverVersion] is ahead, or same version with newer `updated_at`.
  /// Unsynced local rows (`serverVersion == null`) are never replaced by pull.
  static bool shouldApplyRemoteVersion({
    required int? localServerVersion,
    required DateTime localUpdatedAt,
    required int incomingServerVersion,
    required DateTime incomingUpdatedAt,
  }) {
    if (localServerVersion == null) {
      return false;
    }
    final localVer = localServerVersion;
    if (incomingServerVersion < localVer) {
      return false;
    }
    if (incomingServerVersion > localVer) {
      return true;
    }
    return incomingUpdatedAt.isAfter(localUpdatedAt);
  }

  Future<void> _applyRow(SyncedTable<dynamic> mapper, SyncPullRow remote) async {
    final incoming = mapper.fromRemote(remote.row);
    final id = remote.row['id'] as String;
    final incomingVersion = remote.serverVersion;

    if (mapper.tableName == 'batches') {
      final local = await (_db.select(_db.batches)
            ..where((b) => b.id.equals(id)))
          .getSingleOrNull();
      final row = incoming as BatchRow;
      if (local != null) {
        if (local.deletedAt == null &&
            !shouldApplyRemoteVersion(
              localServerVersion: local.serverVersion,
              localUpdatedAt: local.updatedAt,
              incomingServerVersion: incomingVersion,
              incomingUpdatedAt: row.updatedAt,
            )) {
          return;
        }
      }
      await _db.into(_db.batches).insertOnConflictUpdate(
            BatchesCompanion(
              id: Value(row.id),
              farmId: Value(row.farmId),
              createdAt: Value(row.createdAt),
              updatedAt: Value(row.updatedAt),
              deletedAt: Value(row.deletedAt),
              serverVersion: Value(incomingVersion),
              name: Value(row.name),
              birdType: Value(row.birdType),
              initialCount: Value(row.initialCount),
              acquiredOn: Value(row.acquiredOn),
              ageAtAcquisitionDays: Value(row.ageAtAcquisitionDays),
              hatcheryVaccinated: Value(row.hatcheryVaccinated),
              source: Value(row.source),
              status: Value(row.status),
              programmeId: Value(row.programmeId),
              programmeVersion: Value(row.programmeVersion),
              productionType: Value(
                remote.row.containsKey('production_type')
                    ? row.productionType
                    : local?.productionType,
              ),
              programmeContentHash: Value(
                remote.row.containsKey('programme_content_hash')
                    ? row.programmeContentHash
                    : local?.programmeContentHash,
              ),
              notes: Value(row.notes),
            ),
          );
      return;
    }

    if (mapper.tableName == 'vaccination_tasks') {
      final local = await (_db.select(_db.vaccinationTasks)
            ..where((b) => b.id.equals(id)))
          .getSingleOrNull();
      final row = incoming as VaccinationTaskRow;
      if (local != null &&
          !shouldApplyRemoteVersion(
            localServerVersion: local.serverVersion,
            localUpdatedAt: local.updatedAt,
            incomingServerVersion: incomingVersion,
            incomingUpdatedAt: row.updatedAt,
          )) {
        return;
      }
      final mergedStatus = local == null
          ? row.status
          : taskStatusRank(row.status) >= taskStatusRank(local.status)
              ? row.status
              : local.status;

      await _db.into(_db.vaccinationTasks).insertOnConflictUpdate(
            VaccinationTasksCompanion(
              id: Value(row.id),
              farmId: Value(row.farmId),
              createdAt: Value(row.createdAt),
              updatedAt: Value(row.updatedAt),
              deletedAt: Value(row.deletedAt),
              serverVersion: Value(incomingVersion),
              batchId: Value(row.batchId),
              stepId: Value(row.stepId),
              occurrence: Value(
                remote.row.containsKey('occurrence')
                    ? row.occurrence
                    : (local?.occurrence ?? row.occurrence),
              ),
              dueOn: Value(row.dueOn),
              enabled: Value(
                remote.row.containsKey('enabled')
                    ? row.enabled
                    : (local?.enabled ?? row.enabled),
              ),
              status: Value(mergedStatus),
              doneOn: Value(row.doneOn ?? local?.doneOn),
              doneBy: Value(row.doneBy ?? local?.doneBy),
              productUsed: Value(row.productUsed ?? local?.productUsed),
              notes: Value(row.notes ?? local?.notes),
              stepSnapshot: Value(
                remote.row.containsKey('step_snapshot')
                    ? _nonEmpty(row.stepSnapshot)
                    : local?.stepSnapshot,
              ),
              programmeContentHash: Value(
                remote.row.containsKey('programme_content_hash')
                    ? row.programmeContentHash
                    : local?.programmeContentHash,
              ),
              shiftedFrom: Value(row.shiftedFrom ?? local?.shiftedFrom),
            ),
          );
    }
  }

  static String? _nonEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  Future<void> applyPushAck({
    required String table,
    required Map<String, dynamic> row,
    required int serverVersion,
  }) async {
    final id = row['id'] as String;
    if (table == 'batches') {
      await (_db.update(_db.batches)..where((b) => b.id.equals(id))).write(
        BatchesCompanion(serverVersion: Value(serverVersion)),
      );
    } else if (table == 'vaccination_tasks') {
      await (_db.update(_db.vaccinationTasks)..where((b) => b.id.equals(id)))
          .write(
        VaccinationTasksCompanion(serverVersion: Value(serverVersion)),
      );
    }
  }
}
