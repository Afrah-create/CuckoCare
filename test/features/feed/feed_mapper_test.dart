import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:cucocare/features/feed/data/feed_item_synced_table.dart';
import 'package:cucocare/features/feed/data/feed_transaction_synced_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 3, 1, 12);
  final today = DateTime.utc(2026, 3, 1);

  group('FeedItemSyncedTable', () {
    final mapper = FeedItemSyncedTable();

    FeedItemRow sampleRow({DateTime? deletedAt}) => FeedItemRow(
          id: 'item-1',
          farmId: 'farm-1',
          createdAt: now,
          updatedAt: now,
          deletedAt: deletedAt,
          serverVersion: 3,
          name: 'Starter Mash',
          feedType: 'starter',
          unit: 'kg',
          reorderLevel: 50.0,
        );

    test('tableName is feed_items', () {
      expect(mapper.tableName, 'feed_items');
    });

    test('toPayload includes all writable columns', () {
      final payload = mapper.toPayload(sampleRow());
      expect(payload['id'], 'item-1');
      expect(payload['farm_id'], 'farm-1');
      expect(payload['name'], 'Starter Mash');
      expect(payload['feed_type'], 'starter');
      expect(payload['unit'], 'kg');
      expect(payload['reorder_level'], 50.0);
      expect(payload.containsKey('created_at'), isTrue);
      // server_version and updated_at must NOT be in payload (server controls them)
      expect(payload.containsKey('server_version'), isFalse);
      expect(payload.containsKey('updated_at'), isFalse);
    });

    test('toPayload omits reorder_level when null', () {
      final payload = mapper.toPayload(sampleRow()..toString()); // no-op
      final noReorder = FeedItemRow(
        id: 'item-2',
        farmId: 'farm-1',
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
        serverVersion: null,
        name: 'Plain',
        feedType: 'custom',
        unit: 'g',
        reorderLevel: null,
      );
      final p2 = mapper.toPayload(noReorder);
      expect(p2.containsKey('reorder_level'), isFalse);
      expect(payload.containsKey('reorder_level'), isTrue);
    });

    test('fromRemote round-trips basic fields', () {
      final json = {
        'id': 'item-1',
        'farm_id': 'farm-1',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'deleted_at': null,
        'server_version': 3,
        'name': 'Starter Mash',
        'feed_type': 'starter',
        'unit': 'kg',
        'reorder_level': 50.0,
      };
      final row = mapper.fromRemote(json);
      expect(row.id, 'item-1');
      expect(row.name, 'Starter Mash');
      expect(row.reorderLevel, 50.0);
      expect(row.deletedAt, isNull);
    });

    test('fromRemote handles null optional fields', () {
      final json = {
        'id': 'item-2',
        'farm_id': 'farm-1',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'deleted_at': null,
        'server_version': null,
        'name': 'Plain',
        'feed_type': 'custom',
        'unit': 'g',
        'reorder_level': null,
      };
      final row = mapper.fromRemote(json);
      expect(row.reorderLevel, isNull);
      expect(row.serverVersion, isNull);
      expect(row.deletedAt, isNull);
    });

    test('payload keys are a subset of known writable_columns', () {
      const writableColumns = {
        'id',
        'farm_id',
        'name',
        'feed_type',
        'unit',
        'reorder_level',
        'deleted_at',
        'created_at',
      };
      final payload = mapper.toPayload(sampleRow());
      for (final key in payload.keys) {
        expect(writableColumns.contains(key), isTrue,
            reason: 'Unexpected key in payload: $key');
      }
    });
  });

  group('FeedTransactionSyncedTable', () {
    final mapper = FeedTransactionSyncedTable();

    FeedTransactionRow sampleRow({DateTime? deletedAt}) => FeedTransactionRow(
          id: 'tx-1',
          farmId: 'farm-1',
          createdAt: now,
          updatedAt: now,
          deletedAt: deletedAt,
          serverVersion: 1,
          feedItemId: 'item-1',
          batchId: 'batch-1',
          kind: 'purchase',
          quantity: 50.0,
          unitCost: 1000.0,
          occurredOn: today,
        );

    test('tableName is feed_transactions', () {
      expect(mapper.tableName, 'feed_transactions');
    });

    test('kind is appendOnly', () {
      expect(mapper.kind.name, 'appendOnly');
    });

    test('toPayload includes all writable columns', () {
      final payload = mapper.toPayload(sampleRow());
      expect(payload['id'], 'tx-1');
      expect(payload['farm_id'], 'farm-1');
      expect(payload['feed_item_id'], 'item-1');
      expect(payload['batch_id'], 'batch-1');
      expect(payload['kind'], 'purchase');
      expect(payload['quantity'], 50.0);
      expect(payload['unit_cost'], 1000.0);
      // occurred_on should be a date string
      expect(payload['occurred_on'], startsWith('2026-03-01'));
      expect(payload.containsKey('created_at'), isTrue);
      expect(payload.containsKey('server_version'), isFalse);
      expect(payload.containsKey('updated_at'), isFalse);
    });

    test('fromRemote round-trips basic fields', () {
      final json = {
        'id': 'tx-1',
        'farm_id': 'farm-1',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'deleted_at': null,
        'server_version': 1,
        'feed_item_id': 'item-1',
        'batch_id': 'batch-1',
        'kind': 'purchase',
        'quantity': 50.0,
        'unit_cost': 1000.0,
        'occurred_on': '2026-03-01',
      };
      final row = mapper.fromRemote(json);
      expect(row.id, 'tx-1');
      expect(row.kind, 'purchase');
      expect(row.quantity, 50.0);
      expect(row.batchId, 'batch-1');
    });

    test('fromRemote handles null optional fields', () {
      final json = {
        'id': 'tx-2',
        'farm_id': 'farm-1',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'deleted_at': null,
        'server_version': null,
        'feed_item_id': 'item-1',
        'batch_id': null,
        'kind': 'consumption',
        'quantity': 10.0,
        'unit_cost': null,
        'occurred_on': '2026-03-01',
      };
      final row = mapper.fromRemote(json);
      expect(row.batchId, isNull);
      expect(row.unitCost, isNull);
      expect(row.serverVersion, isNull);
    });
  });
}
