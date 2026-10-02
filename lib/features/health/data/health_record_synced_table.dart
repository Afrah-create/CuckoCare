import 'dart:convert';

import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/sync/sync_json.dart';
import '../../../data_platform/sync/synced_table.dart';

class HealthRecordSyncedTable implements SyncedTable<HealthRecordRow> {
  @override
  String get tableName => 'health_records';

  @override
  SyncTableKind get kind => SyncTableKind.appendOnly;

  @override
  String scopeForRow(HealthRecordRow row) => row.farmId;

  @override
  HealthRecordRow fromRemote(Map<String, dynamic> json) {
    final symptoms = json['symptoms'];
    return HealthRecordRow(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      serverVersion: syncJsonInt(json['server_version']),
      batchId: json['batch_id'] as String,
      occurredOn: DateTime.parse(json['occurred_on'] as String),
      summary: json['summary'] as String,
      notes: json['notes'] as String?,
      affectedBirdCount: syncJsonInt(json['affected_bird_count']),
      symptomsJson: symptoms is List
          ? jsonEncode(symptoms)
          : (symptoms as String? ?? '[]'),
      recordKind: json['record_kind'] as String? ?? 'observation',
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
