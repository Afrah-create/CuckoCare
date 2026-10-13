import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/sync/sync_json.dart';
import '../../../data_platform/sync/synced_table.dart';
import 'schedule_dates.dart';

class BatchSyncedTable implements SyncedTable<BatchRow> {
  @override
  String get tableName => 'batches';

  @override
  SyncTableKind get kind => SyncTableKind.mutable;

  @override
  String scopeForRow(BatchRow row) => row.farmId;

  @override
  BatchRow fromRemote(Map<String, dynamic> json) {
    return BatchRow(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      serverVersion: syncJsonInt(json['server_version']),
      name: json['name'] as String,
      birdType: json['bird_type'] as String,
      initialCount: syncJsonInt(json['initial_count']) ?? 0,
      acquiredOn: dateOnlyFromJson(json['acquired_on'] as String),
      ageAtAcquisitionDays: syncJsonInt(json['age_at_acquisition_days']) ?? 1,
      hatcheryVaccinated: json['hatchery_vaccinated'] == null
          ? null
          : syncJsonBool(json['hatchery_vaccinated']),
      source: json['source'] as String?,
      status: json['status'] as String,
      programmeId: json['programme_id'] as String,
      programmeVersion: syncJsonInt(json['programme_version']) ?? 1,
      productionType: json['production_type'] as String?,
      programmeContentHash: json['programme_content_hash'] as String?,
      notes: json['notes'] as String?,
      closedOn: json['closed_on'] == null
          ? null
          : dateOnlyFromJson(json['closed_on'] as String),
      closeReason: json['close_reason'] as String?,
      closeNote: json['close_note'] as String?,
      deletedGroupId: json['deleted_group_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toPayload(BatchRow row) {
    return {
      'id': row.id,
      'farm_id': row.farmId,
      'name': row.name,
      'bird_type': row.birdType,
      'initial_count': row.initialCount,
      'acquired_on': dueOnFromStorage(row.acquiredOn).toIso(),
      'age_at_acquisition_days': row.ageAtAcquisitionDays,
      'hatchery_vaccinated': row.hatcheryVaccinated,
      'source': row.source,
      'status': row.status,
      'programme_id': row.programmeId,
      'programme_version': row.programmeVersion,
      if (row.productionType != null) 'production_type': row.productionType,
      if (row.programmeContentHash != null)
        'programme_content_hash': row.programmeContentHash,
      'notes': row.notes,
      'closed_on': row.closedOn == null
          ? null
          : dueOnFromStorage(row.closedOn!).toIso(),
      'close_reason': row.closeReason,
      'close_note': row.closeNote,
      'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
      'deleted_group_id': row.deletedGroupId,
      'created_at': row.createdAt.toIso8601String(),
    };
  }
}
