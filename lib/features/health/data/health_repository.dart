import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/db/synced_write.dart';
import '../../farms/data/farm_repository.dart';
import 'health_record_synced_table.dart';
import 'vet_assistance_request_synced_table.dart';

class ReportHealthConcernInput {
  ReportHealthConcernInput({
    required this.batchId,
    required this.farmId,
    required this.summary,
    this.notes,
    this.affectedBirdCount,
    this.symptoms = const [],
    this.requestVet = false,
    this.serviceType = 'either',
    this.shareLocation = true,
  });

  final String batchId;
  final String farmId;
  final String summary;
  final String? notes;
  final int? affectedBirdCount;
  final List<String> symptoms;
  final bool requestVet;
  final String serviceType;
  final bool shareLocation;
}

class HealthRepository {
  HealthRepository(
    this._db,
    this._syncedWrite,
    this._farms, {
    Clock? clock,
  })  : _clock = clock ?? SystemClock(),
        _healthMapper = HealthRecordSyncedTable(),
        _vetRequestMapper = VetAssistanceRequestSyncedTable();

  final AppDatabase _db;
  final SyncedWrite _syncedWrite;
  final FarmRepository _farms;
  final Clock _clock;
  final HealthRecordSyncedTable _healthMapper;
  final VetAssistanceRequestSyncedTable _vetRequestMapper;

  Stream<List<HealthRecordRow>> watchForBatch(String batchId) {
    return (_db.select(_db.healthRecords)
          ..where(
            (h) => h.batchId.equals(batchId) & h.deletedAt.isNull(),
          )
          ..orderBy([(h) => OrderingTerm.desc(h.occurredOn)]))
        .watch();
  }

  Future<void> reportConcern(ReportHealthConcernInput input) async {
    final summary = input.summary.trim();
    if (summary.isEmpty) {
      throw ArgumentError('Summary is required');
    }

    final now = _clock.now();
    final healthId = newId();
    final symptomsJson = jsonEncode(
      input.symptoms.map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
    );

    final farm = await _farms.primaryLocalFarm();
    final shareLocation = input.shareLocation &&
        farm != null &&
        farm.latitude != null &&
        farm.longitude != null;

    final healthRow = HealthRecordRow(
      id: healthId,
      farmId: input.farmId,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      serverVersion: null,
      batchId: input.batchId,
      occurredOn: DateTime(now.year, now.month, now.day),
      summary: summary,
      notes: input.notes?.trim().isEmpty == true ? null : input.notes?.trim(),
      affectedBirdCount: input.affectedBirdCount,
      symptomsJson: symptomsJson,
      recordKind: 'observation',
    );

    final ops = <SyncedWriteOp>[
      SyncedWriteOp(
        writeRow: () => _db.into(_db.healthRecords).insert(
              HealthRecordsCompanion.insert(
                id: healthId,
                farmId: input.farmId,
                createdAt: now,
                updatedAt: now,
                batchId: input.batchId,
                occurredOn: healthRow.occurredOn,
                summary: summary,
                notes: Value(healthRow.notes),
                affectedBirdCount: Value(input.affectedBirdCount),
                symptomsJson: Value(symptomsJson),
                recordKind: const Value('observation'),
              ),
            ),
        table: _healthMapper.tableName,
        rowId: healthId,
        op: 'upsert',
        payload: _healthMapper.toPayload(healthRow),
      ),
    ];

    if (input.requestVet) {
      final requestId = newId();
      final requestRow = VetAssistanceRequestRow(
        id: requestId,
        farmId: input.farmId,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
        serverVersion: null,
        batchId: input.batchId,
        healthRecordId: healthId,
        serviceType: input.serviceType,
        status: 'submitted',
        shareLocation: shareLocation,
        priority: 'normal',
        farmerNotes: healthRow.notes,
        assignedVetUserId: null,
      );
      ops.add(
        SyncedWriteOp(
          writeRow: () => _db.into(_db.vetAssistanceRequests).insert(
                VetAssistanceRequestsCompanion.insert(
                  id: requestId,
                  farmId: input.farmId,
                  createdAt: now,
                  updatedAt: now,
                  batchId: input.batchId,
                  healthRecordId: healthId,
                  serviceType: input.serviceType,
                  status: 'submitted',
                  shareLocation: Value(shareLocation),
                  farmerNotes: Value(requestRow.farmerNotes),
                ),
              ),
          table: _vetRequestMapper.tableName,
          rowId: requestId,
          op: 'upsert',
          payload: _vetRequestMapper.toPayload(requestRow),
        ),
      );
    }

    await _syncedWrite.writeSyncedMany(ops);
  }
}
