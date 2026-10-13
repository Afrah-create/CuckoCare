import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/sync/sync_json.dart';
import '../../../data_platform/sync/synced_table.dart';

class VetAssistanceRequestSyncedTable
    implements SyncedTable<VetAssistanceRequestRow> {
  @override
  String get tableName => 'vet_assistance_requests';

  @override
  SyncTableKind get kind => SyncTableKind.mutable;

  @override
  String scopeForRow(VetAssistanceRequestRow row) => row.farmId;

  @override
  VetAssistanceRequestRow fromRemote(Map<String, dynamic> json) {
    return VetAssistanceRequestRow(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      serverVersion: syncJsonInt(json['server_version']),
      batchId: json['batch_id'] as String,
      healthRecordId: json['health_record_id'] as String,
      serviceType: json['service_type'] as String,
      status: json['status'] as String,
      shareLocation: syncJsonBool(json['share_location']),
      priority: json['priority'] as String? ?? 'normal',
      farmerNotes: json['farmer_notes'] as String?,
      assignedVetUserId: json['assigned_vet_user_id'] as String?,
      requestedVetUserId: json['requested_vet_user_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toPayload(VetAssistanceRequestRow row) {
    return {
      'id': row.id,
      'farm_id': row.farmId,
      'batch_id': row.batchId,
      'health_record_id': row.healthRecordId,
      'service_type': row.serviceType,
      'status': row.status,
      'share_location': row.shareLocation,
      'priority': row.priority,
      if (row.farmerNotes != null) 'farmer_notes': row.farmerNotes,
      if (row.requestedVetUserId != null)
        'requested_vet_user_id': row.requestedVetUserId,
      'created_at': row.createdAt.toIso8601String(),
    };
  }
}
