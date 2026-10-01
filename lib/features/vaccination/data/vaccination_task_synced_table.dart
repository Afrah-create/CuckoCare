import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/sync/sync_json.dart';
import '../../../data_platform/sync/synced_table.dart';

class VaccinationTaskSyncedTable implements SyncedTable<VaccinationTaskRow> {
  @override
  String get tableName => 'vaccination_tasks';

  @override
  SyncTableKind get kind => SyncTableKind.mutable;

  @override
  String scopeForRow(VaccinationTaskRow row) => row.farmId;

  @override
  VaccinationTaskRow fromRemote(Map<String, dynamic> json) {
    return VaccinationTaskRow(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      serverVersion: syncJsonInt(json['server_version']),
      batchId: json['batch_id'] as String,
      stepId: json['step_id'] as String,
      occurrence: syncJsonInt(json['occurrence']) ?? 0,
      dueOn: DateTime.parse(json['due_on'] as String),
      enabled: syncJsonBool(json['enabled'], defaultValue: true),
      status: json['status'] as String,
      doneOn: json['done_on'] == null
          ? null
          : DateTime.parse(json['done_on'] as String),
      doneBy: json['done_by'] as String?,
      productUsed: json['product_used'] as String?,
      notes: json['notes'] as String?,
      stepSnapshot: json['step_snapshot'] as String?,
      programmeContentHash: json['programme_content_hash'] as String?,
      shiftedFrom: json['shifted_from'] == null
          ? null
          : DateTime.parse(json['shifted_from'] as String),
    );
  }

  @override
  Map<String, dynamic> toPayload(VaccinationTaskRow row) {
    return {
      'id': row.id,
      'farm_id': row.farmId,
      'batch_id': row.batchId,
      'step_id': row.stepId,
      'occurrence': row.occurrence,
      'due_on': row.dueOn.toIso8601String().substring(0, 10),
      'enabled': row.enabled,
      'status': row.status,
      'done_on': row.doneOn?.toIso8601String().substring(0, 10),
      'done_by': row.doneBy,
      'product_used': row.productUsed,
      'notes': row.notes,
      if (row.stepSnapshot != null) 'step_snapshot': row.stepSnapshot,
      if (row.programmeContentHash != null)
        'programme_content_hash': row.programmeContentHash,
      if (row.shiftedFrom != null)
        'shifted_from': row.shiftedFrom!.toIso8601String().substring(0, 10),
      'created_at': row.createdAt.toIso8601String(),
    };
  }
}
