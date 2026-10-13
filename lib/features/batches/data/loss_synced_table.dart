import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/sync/sync_json.dart';
import '../../../data_platform/sync/synced_table.dart';
import 'schedule_dates.dart';

/// Loss records sync as a mutable table: last write wins on the row.
class LossSyncedTable implements SyncedTable<MortalityRecordRow> {
  @override
  String get tableName => 'mortality_records';

  @override
  SyncTableKind get kind => SyncTableKind.mutable;

  @override
  String scopeForRow(MortalityRecordRow row) => row.farmId;

  @override
  MortalityRecordRow fromRemote(Map<String, dynamic> json) {
    return MortalityRecordRow(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: _instant(json['deleted_at']),
      serverVersion: syncJsonInt(json['server_version']),
      batchId: json['batch_id'] as String,
      count: syncJsonInt(json['count']) ?? 0,
      kind: json['kind'] as String? ?? 'died',
      suspectedCause: json['suspected_cause'] as String?,
      occurredOn: dateOnlyFromJson(json['occurred_on'] as String),
      notes: json['notes'] as String?,
      editedAt: _instant(json['edited_at']),
      deletedGroupId: json['deleted_group_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toPayload(MortalityRecordRow row) {
    return {
      'id': row.id,
      'farm_id': row.farmId,
      'batch_id': row.batchId,
      'count': row.count,
      'kind': row.kind,
      'suspected_cause': row.suspectedCause,
      'occurred_on': dueOnFromStorage(row.occurredOn).toIso(),
      'notes': row.notes,
      'edited_at': row.editedAt?.toUtc().toIso8601String(),
      'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
      'deleted_group_id': row.deletedGroupId,
      'created_at': row.createdAt.toUtc().toIso8601String(),
    };
  }

  static DateTime? _instant(Object? value) =>
      value == null ? null : DateTime.parse(value as String);
}
