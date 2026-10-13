import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/sync/sync_json.dart';
import '../../../data_platform/sync/synced_table.dart';

class FeedTransactionSyncedTable implements SyncedTable<FeedTransactionRow> {
  @override
  String get tableName => 'feed_transactions';

  /// Append-only per architecture rule 6 — feed_transactions are never
  /// updated in place. Corrections come in as reversal/adjustment rows.
  @override
  SyncTableKind get kind => SyncTableKind.appendOnly;

  @override
  String scopeForRow(FeedTransactionRow row) => row.farmId;

  @override
  FeedTransactionRow fromRemote(Map<String, dynamic> json) {
    return FeedTransactionRow(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      serverVersion: syncJsonInt(json['server_version']),
      feedItemId: json['feed_item_id'] as String,
      batchId: json['batch_id'] as String?,
      kind: json['kind'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitCost: (json['unit_cost'] as num?)?.toDouble(),
      occurredOn: DateTime.parse(json['occurred_on'] as String),
    );
  }

  @override
  Map<String, dynamic> toPayload(FeedTransactionRow row) {
    return {
      'id': row.id,
      'farm_id': row.farmId,
      'feed_item_id': row.feedItemId,
      if (row.batchId != null) 'batch_id': row.batchId,
      'kind': row.kind,
      'quantity': row.quantity,
      if (row.unitCost != null) 'unit_cost': row.unitCost,
      'occurred_on': row.occurredOn.toIso8601String().substring(0, 10),
      'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
      'created_at': row.createdAt.toIso8601String(),
    };
  }
}
