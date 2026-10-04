import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/db/synced_write.dart';
import '../../../data_platform/supabase/offline_first_auth.dart';
import '../../farms/data/farm_repository.dart';
import 'health_incident_photo_storage.dart';
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
    this.localPhotoPaths = const [],
    this.requestVet = true,
    this.serviceType = 'either',
    this.shareLocation = true,
    this.requestedVetUserId,
  });

  final String batchId;
  final String farmId;
  final String summary;
  final String? notes;
  final int? affectedBirdCount;
  final List<String> symptoms;
  final List<String> localPhotoPaths;
  final bool requestVet;
  final String serviceType;
  final bool shareLocation;
  final String? requestedVetUserId;
}

class FarmerIncidentEntry {
  FarmerIncidentEntry({
    required this.record,
    this.batchName,
    this.vetRequest,
  });

  final HealthRecordRow record;
  final String? batchName;
  final VetAssistanceRequestRow? vetRequest;
}

class HealthRepository {
  HealthRepository(
    this._db,
    this._syncedWrite, {
    FarmRepository? farms,
    Future<FarmRow?> Function()? resolvePrimaryFarm,
    Clock? clock,
    HealthIncidentPhotoStorage? photoStorage,
  })  : assert(farms != null || resolvePrimaryFarm != null),
        _farms = farms,
        _resolvePrimaryFarm = resolvePrimaryFarm,
        _clock = clock ?? SystemClock(),
        _healthMapper = HealthRecordSyncedTable(),
        _vetRequestMapper = VetAssistanceRequestSyncedTable(),
        _photoStorage = photoStorage ?? HealthIncidentPhotoStorage();

  final AppDatabase _db;
  final SyncedWrite _syncedWrite;
  final FarmRepository? _farms;
  final Future<FarmRow?> Function()? _resolvePrimaryFarm;
  final Clock _clock;
  final HealthRecordSyncedTable _healthMapper;
  final VetAssistanceRequestSyncedTable _vetRequestMapper;
  final HealthIncidentPhotoStorage _photoStorage;

  Stream<List<HealthRecordRow>> watchForBatch(String batchId) {
    return (_db.select(_db.healthRecords)
          ..where(
            (h) => h.batchId.equals(batchId) & h.deletedAt.isNull(),
          )
          ..orderBy([(h) => OrderingTerm.desc(h.occurredOn)]))
        .watch();
  }

  Stream<List<FarmerIncidentEntry>> watchFarmIncidents(String farmId) {
    final healthQuery = (_db.select(_db.healthRecords)
          ..where(
            (h) =>
                h.farmId.equals(farmId) &
                h.deletedAt.isNull() &
                h.recordKind.equals('incident'),
          )
          ..orderBy([(h) => OrderingTerm.desc(h.occurredOn)]))
        .watch();

    return healthQuery.asyncMap((records) async {
      if (records.isEmpty) {
        return const <FarmerIncidentEntry>[];
      }
      final batchIds = records.map((r) => r.batchId).toSet();
      final batches = await (_db.select(_db.batches)
            ..where((b) => b.id.isIn(batchIds.toList())))
          .get();
      final batchNames = {for (final b in batches) b.id: b.name};

      final healthIds = records.map((r) => r.id).toList();
      final requests = await (_db.select(_db.vetAssistanceRequests)
            ..where(
              (v) =>
                  v.healthRecordId.isIn(healthIds) & v.deletedAt.isNull(),
            ))
          .get();
      final byHealth = {
        for (final r in requests) r.healthRecordId: r,
      };

      return records
          .map(
            (record) => FarmerIncidentEntry(
              record: record,
              batchName: batchNames[record.batchId],
              vetRequest: byHealth[record.id],
            ),
          )
          .toList();
    });
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
    final pendingPhotosJson = jsonEncode(input.localPhotoPaths);

    final farm = await _loadPrimaryFarm();
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
      recordKind: 'incident',
      photoObjectKeysJson: '[]',
      pendingPhotoPathsJson: pendingPhotosJson,
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
                recordKind: const Value('incident'),
                pendingPhotoPathsJson: Value(pendingPhotosJson),
              ),
            ),
        table: _healthMapper.tableName,
        rowId: healthId,
        op: 'upsert',
        payload: _healthMapper.toPayload(healthRow),
      ),
    ];

    final requestId = newId();
    final notifyVet = input.requestVet;
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
      status: notifyVet ? 'submitted' : 'draft',
      shareLocation: shareLocation,
      priority: input.affectedBirdCount != null && input.affectedBirdCount! > 50
          ? 'urgent'
          : 'normal',
      farmerNotes: _vetNotesFromIncident(healthRow),
      assignedVetUserId: null,
      requestedVetUserId: notifyVet ? input.requestedVetUserId : null,
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
                status: requestRow.status,
                shareLocation: Value(shareLocation),
                priority: Value(requestRow.priority),
                farmerNotes: Value(requestRow.farmerNotes),
                requestedVetUserId: Value(requestRow.requestedVetUserId),
              ),
            ),
        table: _vetRequestMapper.tableName,
        rowId: requestId,
        op: 'upsert',
        payload: _vetRequestMapper.toPayload(requestRow),
      ),
    );

    await _syncedWrite.writeSyncedMany(ops);
    await flushPendingPhotos(healthRecordId: healthId);
  }

  Future<FarmRow?> _loadPrimaryFarm() async {
    final override = _resolvePrimaryFarm;
    if (override != null) {
      return override();
    }
    return _farms!.primaryLocalFarm();
  }

  /// Sends a draft vet request to the network inbox (status → submitted).
  Future<void> publishDraftVetRequest(String requestId) async {
    final existing = await (_db.select(_db.vetAssistanceRequests)
          ..where(
            (v) => v.id.equals(requestId) & v.deletedAt.isNull(),
          ))
        .getSingleOrNull();
    if (existing == null) {
      throw StateError('Vet request not found');
    }
    if (existing.status != 'draft') {
      return;
    }
    final now = _clock.now();
    final updated = existing.copyWith(
      status: 'submitted',
      updatedAt: now,
    );
    await _syncedWrite.writeSynced(
      writeRow: () => (_db.update(_db.vetAssistanceRequests)
            ..where((v) => v.id.equals(requestId)))
          .write(
        VetAssistanceRequestsCompanion(
          status: const Value('submitted'),
          updatedAt: Value(now),
        ),
      ),
      table: _vetRequestMapper.tableName,
      rowId: requestId,
      op: 'upsert',
      payload: _vetRequestMapper.toPayload(updated),
    );
  }

  String? _vetNotesFromIncident(HealthRecordRow row) {
    final parts = <String>[row.summary];
    if (row.affectedBirdCount != null) {
      parts.add('Birds affected: ${row.affectedBirdCount}');
    }
    if (row.notes != null && row.notes!.isNotEmpty) {
      parts.add(row.notes!);
    }
    return parts.join('\n');
  }

  /// Uploads any pending local photos and updates the health record outbox row.
  Future<void> flushPendingPhotos({required String healthRecordId}) async {
    if (!await ensureSupabaseSessionForNetwork()) {
      return;
    }

    final row = await (_db.select(_db.healthRecords)
          ..where((h) => h.id.equals(healthRecordId) & h.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) {
      return;
    }

    final pending = (jsonDecode(row.pendingPhotoPathsJson) as List)
        .map((e) => e.toString())
        .where((p) => p.isNotEmpty)
        .toList();
    if (pending.isEmpty) {
      return;
    }

    final newKeys = await _photoStorage.uploadPhotos(
      healthRecordId: healthRecordId,
      localPaths: pending,
    );
    if (newKeys.isEmpty) {
      return;
    }

    final existingKeys = (jsonDecode(row.photoObjectKeysJson) as List)
        .map((e) => e.toString())
        .toList();
    final mergedKeys = [...existingKeys, ...newKeys];
    final keysJson = jsonEncode(mergedKeys);
    final now = _clock.now();

    final updated = row.copyWith(
      photoObjectKeysJson: keysJson,
      pendingPhotoPathsJson: '[]',
      updatedAt: now,
    );

    await _syncedWrite.writeSynced(
      writeRow: () => (_db.update(_db.healthRecords)
            ..where((h) => h.id.equals(healthRecordId)))
          .write(
        HealthRecordsCompanion(
          photoObjectKeysJson: Value(keysJson),
          pendingPhotoPathsJson: const Value('[]'),
          updatedAt: Value(now),
        ),
      ),
      table: _healthMapper.tableName,
      rowId: healthRecordId,
      op: 'upsert',
      payload: _healthMapper.toPayload(updated),
    );
  }

  Future<void> flushAllPendingIncidentPhotos() async {
    final rows = await (_db.select(_db.healthRecords)
          ..where(
            (h) =>
                h.deletedAt.isNull() &
                h.pendingPhotoPathsJson.isNotValue('[]'),
          ))
        .get();
    for (final row in rows) {
      await flushPendingPhotos(healthRecordId: row.id);
    }
  }
}
