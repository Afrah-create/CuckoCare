import 'dart:convert';

import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/sync/sync_json.dart';
import '../../../data_platform/sync/synced_table.dart';

class HealthRecordSyncedTable implements SyncedTable<HealthRecordRow> {
  @override
  String get tableName => 'health_records';

  @override
  SyncTableKind get kind => SyncTableKind.mutable;

  @override
  String scopeForRow(HealthRecordRow row) => row.farmId;

  @override
  HealthRecordRow fromRemote(Map<String, dynamic> json) {
    final symptoms = json['symptoms'];
    return HealthRecordRow(
      id: syncJsonString(json['id'])!,
      farmId: syncJsonString(json['farm_id'])!,
      createdAt: syncJsonDateTime(json['created_at'])!,
      updatedAt: syncJsonDateTime(json['updated_at'])!,
      deletedAt: syncJsonDateTime(json['deleted_at']),
      serverVersion: syncJsonInt(json['server_version']),
      batchId: syncJsonString(json['batch_id'])!,
      occurredOn: syncJsonDateTime(json['occurred_on'])!,
      summary: syncJsonString(json['summary']) ?? '',
      notes: syncJsonString(json['notes']),
      affectedBirdCount: syncJsonInt(json['affected_bird_count']),
      symptomsJson: symptoms is List
          ? jsonEncode(symptoms)
          : (syncJsonString(symptoms) ?? '[]'),
      recordKind: syncJsonString(json['record_kind']) ?? 'observation',
      photoObjectKeysJson: _photoKeysJson(json['photo_object_keys']),
      pendingPhotoPathsJson: '[]',
    );
  }

  static String _photoKeysJson(dynamic raw) {
    if (raw is List) {
      return jsonEncode(raw.map((e) => e.toString()).toList());
    }
    return '[]';
  }

  @override
  Map<String, dynamic> toPayload(HealthRecordRow row) {
    final keys = jsonDecode(row.photoObjectKeysJson) as List;
    return {
      'id': row.id,
      'farm_id': row.farmId,
      'batch_id': row.batchId,
      'occurred_on': row.occurredOn.toIso8601String().substring(0, 10),
      'summary': row.summary,
      if (row.notes != null) 'notes': row.notes,
      if (row.affectedBirdCount != null)
        'affected_bird_count': row.affectedBirdCount,
      'symptoms': jsonDecode(row.symptomsJson),
      'record_kind': row.recordKind,
      'photo_object_keys': keys,
      'created_at': row.createdAt.toIso8601String(),
    };
  }
}
