import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'remote_sync_api.dart';
import 'synced_table.dart';
import '../../features/batches/data/batch_synced_table.dart';
import '../../features/batches/data/loss_synced_table.dart';
import '../../features/farms/data/farm_synced_table.dart';
import '../../features/health/data/health_record_synced_table.dart';
import '../../features/health/data/vet_assistance_request_synced_table.dart';
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
  final _losses = LossSyncedTable();
  final _health = HealthRecordSyncedTable();
  final _vetRequests = VetAssistanceRequestSyncedTable();
  final _farms = FarmSyncedTable();

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
        'mortality_records' => _losses,
        'health_records' => _health,
        'vet_assistance_requests' => _vetRequests,
        'farms' => _farms,
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
              closedOn: Value(
                remote.row.containsKey('closed_on')
                    ? row.closedOn
                    : local?.closedOn,
              ),
              closeReason: Value(
                remote.row.containsKey('close_reason')
                    ? row.closeReason
                    : local?.closeReason,
              ),
              closeNote: Value(
                remote.row.containsKey('close_note')
                    ? row.closeNote
                    : local?.closeNote,
              ),
              deletedGroupId: Value(
                remote.row.containsKey('deleted_group_id')
                    ? row.deletedGroupId
                    : local?.deletedGroupId,
              ),
            ),
          );
      return;
    }

    if (mapper.tableName == 'mortality_records') {
      final local = await (_db.select(_db.mortalityRecords)
            ..where((b) => b.id.equals(id)))
          .getSingleOrNull();
      final row = incoming as MortalityRecordRow;
      if (local != null &&
          !shouldApplyRemoteVersion(
            localServerVersion: local.serverVersion,
            localUpdatedAt: local.updatedAt,
            incomingServerVersion: incomingVersion,
            incomingUpdatedAt: row.updatedAt,
          )) {
        return;
      }
      await _db.into(_db.mortalityRecords).insertOnConflictUpdate(
            MortalityRecordsCompanion(
              id: Value(row.id),
              farmId: Value(row.farmId),
              createdAt: Value(row.createdAt),
              updatedAt: Value(row.updatedAt),
              deletedAt: Value(row.deletedAt),
              serverVersion: Value(incomingVersion),
              batchId: Value(row.batchId),
              count: Value(row.count),
              kind: Value(row.kind),
              suspectedCause: Value(row.suspectedCause),
              occurredOn: Value(row.occurredOn),
              notes: Value(row.notes),
              editedAt: Value(row.editedAt),
              deletedGroupId: Value(row.deletedGroupId),
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
              deletedGroupId: Value(
                remote.row.containsKey('deleted_group_id')
                    ? row.deletedGroupId
                    : local?.deletedGroupId,
              ),
            ),
          );
      return;
    }

    if (mapper.tableName == 'health_records') {
      final local = await (_db.select(_db.healthRecords)
            ..where((b) => b.id.equals(id)))
          .getSingleOrNull();
      final row = incoming as HealthRecordRow;
      if (local != null &&
          !shouldApplyRemoteVersion(
            localServerVersion: local.serverVersion,
            localUpdatedAt: local.updatedAt,
            incomingServerVersion: incomingVersion,
            incomingUpdatedAt: row.updatedAt,
          )) {
        return;
      }
      await _db.into(_db.healthRecords).insertOnConflictUpdate(
            HealthRecordsCompanion(
              id: Value(row.id),
              farmId: Value(row.farmId),
              createdAt: Value(row.createdAt),
              updatedAt: Value(row.updatedAt),
              deletedAt: Value(row.deletedAt),
              serverVersion: Value(incomingVersion),
              batchId: Value(row.batchId),
              occurredOn: Value(row.occurredOn),
              summary: Value(row.summary),
              notes: Value(row.notes),
              affectedBirdCount: Value(row.affectedBirdCount),
              symptomsJson: Value(row.symptomsJson),
              recordKind: Value(row.recordKind),
              photoObjectKeysJson: Value(row.photoObjectKeysJson),
            ),
          );
      return;
    }

    if (mapper.tableName == 'vet_assistance_requests') {
      final local = await (_db.select(_db.vetAssistanceRequests)
            ..where((b) => b.id.equals(id)))
          .getSingleOrNull();
      final row = incoming as VetAssistanceRequestRow;
      if (local != null &&
          !shouldApplyRemoteVersion(
            localServerVersion: local.serverVersion,
            localUpdatedAt: local.updatedAt,
            incomingServerVersion: incomingVersion,
            incomingUpdatedAt: row.updatedAt,
          )) {
        return;
      }
      await _db.into(_db.vetAssistanceRequests).insertOnConflictUpdate(
            VetAssistanceRequestsCompanion(
              id: Value(row.id),
              farmId: Value(row.farmId),
              createdAt: Value(row.createdAt),
              updatedAt: Value(row.updatedAt),
              deletedAt: Value(row.deletedAt),
              serverVersion: Value(incomingVersion),
              batchId: Value(row.batchId),
              healthRecordId: Value(row.healthRecordId),
              serviceType: Value(row.serviceType),
              status: Value(row.status),
              shareLocation: Value(row.shareLocation),
              priority: Value(row.priority),
              farmerNotes: Value(row.farmerNotes),
              assignedVetUserId: Value(row.assignedVetUserId),
              requestedVetUserId: Value(row.requestedVetUserId),
            ),
          );
      return;
    }

    if (mapper.tableName == 'farms') {
      final local =
          await (_db.select(_db.farms)..where((b) => b.id.equals(id)))
              .getSingleOrNull();
      final row = incoming as FarmRow;
      if (local != null &&
          !shouldApplyRemoteVersion(
            localServerVersion: local.serverVersion,
            localUpdatedAt: local.updatedAt,
            incomingServerVersion: incomingVersion,
            incomingUpdatedAt: row.updatedAt,
          )) {
        return;
      }
      await _db.into(_db.farms).insertOnConflictUpdate(
            FarmsCompanion(
              id: Value(row.id),
              farmId: Value(row.farmId),
              createdAt: Value(row.createdAt),
              updatedAt: Value(row.updatedAt),
              deletedAt: Value(row.deletedAt),
              serverVersion: Value(incomingVersion),
              name: Value(row.name),
              location: Value(row.location ?? local?.location),
              district: Value(row.district ?? local?.district),
              village: Value(row.village ?? local?.village),
              phone: Value(row.phone ?? local?.phone),
              altPhone: Value(row.altPhone ?? local?.altPhone),
              notes: Value(row.notes ?? local?.notes),
              profileCompletedAt:
                  Value(row.profileCompletedAt ?? local?.profileCompletedAt),
              latitude: Value(
                remote.row.containsKey('latitude')
                    ? row.latitude
                    : local?.latitude,
              ),
              longitude: Value(
                remote.row.containsKey('longitude')
                    ? row.longitude
                    : local?.longitude,
              ),
              locationAccuracyM: Value(
                remote.row.containsKey('location_accuracy_m')
                    ? row.locationAccuracyM
                    : local?.locationAccuracyM,
              ),
              locationCapturedAt: Value(
                remote.row.containsKey('location_captured_at')
                    ? row.locationCapturedAt
                    : local?.locationCapturedAt,
              ),
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
    } else if (table == 'mortality_records') {
      await (_db.update(_db.mortalityRecords)..where((b) => b.id.equals(id)))
          .write(
        MortalityRecordsCompanion(serverVersion: Value(serverVersion)),
      );
    } else if (table == 'health_records') {
      await (_db.update(_db.healthRecords)..where((b) => b.id.equals(id)))
          .write(
        HealthRecordsCompanion(serverVersion: Value(serverVersion)),
      );
    } else if (table == 'vet_assistance_requests') {
      await (_db.update(_db.vetAssistanceRequests)..where((b) => b.id.equals(id)))
          .write(
        VetAssistanceRequestsCompanion(serverVersion: Value(serverVersion)),
      );
    } else if (table == 'farms') {
      await (_db.update(_db.farms)..where((b) => b.id.equals(id))).write(
        FarmsCompanion(serverVersion: Value(serverVersion)),
      );
    }
  }
}
