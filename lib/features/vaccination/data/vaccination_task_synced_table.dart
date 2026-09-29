import '../../../data_platform/db/app_database.dart';
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
      serverVersion: json['server_version'] as int?,
      batchId: json['batch_id'] as String,
      stepId: json['step_id'] as String,
      dueOn: DateTime.parse(json['due_on'] as String),
      status: json['status'] as String,
      doneOn: json['done_on'] == null
          ? null
          : DateTime.parse(json['done_on'] as String),
      productUsed: json['product_used'] as String?,
      notes: json['notes'] as String?,
    );
  }

  @override
  Map<String, dynamic> toPayload(VaccinationTaskRow row) {
    return {
      'id': row.id,
      'farm_id': row.farmId,
      'batch_id': row.batchId,
      'step_id': row.stepId,
      'due_on': row.dueOn.toIso8601String().substring(0, 10),
      'status': row.status,
      'done_on': row.doneOn?.toIso8601String().substring(0, 10),
      'product_used': row.productUsed,
      'notes': row.notes,
      'created_at': row.createdAt.toIso8601String(),
    };
  }
}
