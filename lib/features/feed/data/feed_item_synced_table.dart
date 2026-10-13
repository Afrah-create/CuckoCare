import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/sync/sync_json.dart';
import '../../../data_platform/sync/synced_table.dart';

class FeedItemSyncedTable implements SyncedTable<FeedItemRow> {
  @override
  String get tableName => 'feed_items';

  @override
  SyncTableKind get kind => SyncTableKind.mutable;

  @override
  String scopeForRow(FeedItemRow row) => row.farmId;

  @override
  FeedItemRow fromRemote(Map<String, dynamic> json) {
    return FeedItemRow(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      serverVersion: syncJsonInt(json['server_version']),
      name: json['name'] as String,
      feedType: json['feed_type'] as String,
      unit: json['unit'] as String,
      reorderLevel: (json['reorder_level'] as num?)?.toDouble(),
    );
  }

  @override
  Map<String, dynamic> toPayload(FeedItemRow row) {
    return {
      'id': row.id,
      'farm_id': row.farmId,
      'name': row.name,
      'feed_type': row.feedType,
      'unit': row.unit,
      if (row.reorderLevel != null) 'reorder_level': row.reorderLevel,
      'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
      'created_at': row.createdAt.toIso8601String(),
    };
  }
}
