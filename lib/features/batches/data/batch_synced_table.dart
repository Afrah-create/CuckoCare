import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/sync/synced_table.dart';

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
      serverVersion: json['server_version'] as int?,
      name: json['name'] as String,
      birdType: json['bird_type'] as String,
      initialCount: json['initial_count'] as int,
      acquiredOn: DateTime.parse(json['acquired_on'] as String),
      ageAtAcquisitionDays: json['age_at_acquisition_days'] as int? ?? 0,
      hatcheryVaccinated: json['hatchery_vaccinated'] as bool?,
      source: json['source'] as String?,
      status: json['status'] as String,
      programmeId: json['programme_id'] as String,
      programmeVersion: json['programme_version'] as int,
      notes: json['notes'] as String?,
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
      'acquired_on': row.acquiredOn.toIso8601String().substring(0, 10),
      'age_at_acquisition_days': row.ageAtAcquisitionDays,
      'hatchery_vaccinated': row.hatcheryVaccinated,
      'source': row.source,
      'status': row.status,
      'programme_id': row.programmeId,
      'programme_version': row.programmeVersion,
      'notes': row.notes,
      'created_at': row.createdAt.toIso8601String(),
    };
  }
}
