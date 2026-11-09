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
      id: syncJsonString(json['id'])!,
      farmId: syncJsonString(json['farm_id'])!,
      createdAt: syncJsonDateTime(json['created_at'])!,
      updatedAt: syncJsonDateTime(json['updated_at'])!,
      deletedAt: syncJsonDateTime(json['deleted_at']),
      serverVersion: syncJsonInt(json['server_version']),
      batchId: syncJsonString(json['batch_id'])!,
      healthRecordId: syncJsonString(json['health_record_id'])!,
      serviceType: syncJsonString(json['service_type']) ?? 'either',
      status: syncJsonString(json['status']) ?? 'submitted',
      shareLocation: syncJsonBool(json['share_location']),
      priority: syncJsonString(json['priority']) ?? 'normal',
      farmerNotes: syncJsonString(json['farmer_notes']),
      assignedVetUserId: syncJsonString(json['assigned_vet_user_id']),
      requestedVetUserId: syncJsonString(json['requested_vet_user_id']),
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
      if (row.requestedVetUserId != null &&
          row.requestedVetUserId!.trim().isNotEmpty)
        'requested_vet_user_id': row.requestedVetUserId,
      'created_at': row.createdAt.toIso8601String(),
    };
  }
}
