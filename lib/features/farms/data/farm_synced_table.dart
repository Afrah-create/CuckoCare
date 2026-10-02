import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/sync/sync_json.dart';
import '../../../data_platform/sync/synced_table.dart';

class FarmSyncedTable implements SyncedTable<FarmRow> {
  @override
  String get tableName => 'farms';

  @override
  SyncTableKind get kind => SyncTableKind.mutable;

  @override
  String scopeForRow(FarmRow row) => row.id;

  @override
  FarmRow fromRemote(Map<String, dynamic> json) {
    return FarmRow(
      id: json['id'] as String,
      farmId: json['farm_id'] as String? ?? json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      serverVersion: syncJsonInt(json['server_version']),
      name: json['name'] as String,
      location: json['location'] as String?,
      district: json['district'] as String?,
      village: json['village'] as String?,
      phone: json['phone'] as String?,
      altPhone: json['alt_phone'] as String?,
      notes: json['notes'] as String?,
      profileCompletedAt: json['profile_completed_at'] == null
          ? null
          : DateTime.parse(json['profile_completed_at'] as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationAccuracyM: (json['location_accuracy_m'] as num?)?.toDouble(),
      locationCapturedAt: json['location_captured_at'] == null
          ? null
          : DateTime.parse(json['location_captured_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toPayload(FarmRow row) {
    return {
      'id': row.id,
      'farm_id': row.farmId,
      'name': row.name,
      if (row.location != null) 'location': row.location,
      if (row.district != null) 'district': row.district,
      if (row.village != null) 'village': row.village,
      if (row.phone != null) 'phone': row.phone,
      if (row.altPhone != null) 'alt_phone': row.altPhone,
      if (row.notes != null) 'notes': row.notes,
      if (row.latitude != null) 'latitude': row.latitude,
      if (row.longitude != null) 'longitude': row.longitude,
      if (row.locationAccuracyM != null)
        'location_accuracy_m': row.locationAccuracyM,
      if (row.locationCapturedAt != null)
        'location_captured_at': row.locationCapturedAt!.toIso8601String(),
      'created_at': row.createdAt.toIso8601String(),
    };
  }
}
