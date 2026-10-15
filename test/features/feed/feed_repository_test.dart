import 'package:cucocare/core/time/clock.dart';
import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:cucocare/features/feed/data/feed_repository.dart';
import 'package:cucocare/features/feed/domain/feed_models.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _farmId = 'farm-1';
final _now = DateTime.utc(2026, 3, 1, 9);
final _today = DateTime.utc(2026, 3, 1);

void main() {
  late AppDatabase db;
  late FeedRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = FeedRepository(db, FixedClock(_now));
  });

  tearDown(() => db.close());

  // Helper: add an item and return the row.
  Future<FeedItemRow> addItem({
    String name = 'Test Feed',
    double? reorderLevel,
  }) =>
      repo.addFeedItem(
        farmId: _farmId,
        input: FeedItemInput(
          name: name,
          feedType: FeedTypes.starter,
          unit: FeedUnits.kg,
          reorderLevel: reorderLevel,
        ),
      );

  group('addFeedItem', () {
    test('creates a row in feedItems', () async {
      final row = await addItem();
      final found = await repo.findFeedItem(row.id);
      expect(found, isNotNull);
      expect(found!.name, 'Test Feed');
    });

    test('inserts an outbox row for the item', () async {
      final row = await addItem();
      final outboxRows = await (db.select(db.outbox)
            ..where((o) => o.rowId.equals(row.id)))
          .get();
      expect(outboxRows, hasLength(1));
      expect(outboxRows.first.targetTable, 'feed_items');
    });
  });

  group('recordTransaction — purchase', () {
    test('creates a transaction row', () async {
      final item = await addItem();
      await repo.recordTransaction(
        farmId: _farmId,
        input: FeedTransactionInput(
          feedItemId: item.id,
          kind: FeedTransactionKind.purchase,
          quantity: 100,
          occurredOn: _today,
          unitCost: 500,
        ),
      );
      final txs = await (db.select(db.feedTransactions)
            ..where((t) => t.feedItemId.equals(item.id)))
          .get();
      expect(txs, hasLength(1));
      expect(txs.first.kind, 'purchase');
      expect(txs.first.quantity, 100);
    });

    test('outbox row is inserted for transaction', () async {
      final item = await addItem();
      final tx = await repo.recordTransaction(
        farmId: _farmId,
        input: FeedTransactionInput(
          feedItemId: item.id,
          kind: FeedTransactionKind.purchase,
          quantity: 50,
          occurredOn: _today,
        ),
      );
      final outboxRows = await (db.select(db.outbox)
            ..where((o) => o.rowId.equals(tx.id)))
          .get();
      expect(outboxRows, hasLength(1));
      expect(outboxRows.first.targetTable, 'feed_transactions');
    });
  });

  group('recordTransaction — consumption', () {
    test('records a consumption transaction', () async {
      final item = await addItem();
      final tx = await repo.recordTransaction(
        farmId: _farmId,
        input: FeedTransactionInput(
          feedItemId: item.id,
          kind: FeedTransactionKind.consumption,
          quantity: 20,
          occurredOn: _today,
        ),
      );
      expect(tx.kind, 'consumption');
      expect(tx.quantity, 20);
    });
  });

  group('recordTransaction — signed adjustment', () {
    test('positive adjustment is stored as-is', () async {
      final item = await addItem();
      final tx = await repo.recordTransaction(
        farmId: _farmId,
        input: FeedTransactionInput(
          feedItemId: item.id,
          kind: FeedTransactionKind.adjustment,
          quantity: 5,
          occurredOn: _today,
        ),
      );
      expect(tx.quantity, 5);
      expect(tx.kind, 'adjustment');
    });

    test('negative adjustment is stored as-is', () async {
      final item = await addItem();
      final tx = await repo.recordTransaction(
        farmId: _farmId,
        input: FeedTransactionInput(
          feedItemId: item.id,
          kind: FeedTransactionKind.adjustment,
          quantity: -5,
          occurredOn: _today,
        ),
      );
      expect(tx.quantity, -5);
    });

    test('zero adjustment throws ArgumentError', () async {
      final item = await addItem();
      await expectLater(
        repo.recordTransaction(
          farmId: _farmId,
          input: FeedTransactionInput(
            feedItemId: item.id,
            kind: FeedTransactionKind.adjustment,
            quantity: 0,
            occurredOn: _today,
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('_assertValidQuantity', () {
    test('purchase with zero quantity throws', () async {
      final item = await addItem();
      await expectLater(
        repo.recordTransaction(
          farmId: _farmId,
          input: FeedTransactionInput(
            feedItemId: item.id,
            kind: FeedTransactionKind.purchase,
            quantity: 0,
            occurredOn: _today,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('consumption with negative quantity throws', () async {
      final item = await addItem();
      await expectLater(
        repo.recordTransaction(
          farmId: _farmId,
          input: FeedTransactionInput(
            feedItemId: item.id,
            kind: FeedTransactionKind.consumption,
            quantity: -1,
            occurredOn: _today,
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('deleteFeedItem', () {
    test('soft-deletes the item (sets deletedAt)', () async {
      final item = await addItem();
      await repo.deleteFeedItem(_domainItem(item));

      final after = await (db.select(db.feedItems)
            ..where((f) => f.id.equals(item.id)))
          .getSingleOrNull();
      expect(after, isNotNull);
      expect(after!.deletedAt, isNotNull);
    });

    test('transactions remain after item soft-delete', () async {
      final item = await addItem();
      await repo.recordTransaction(
        farmId: _farmId,
        input: FeedTransactionInput(
          feedItemId: item.id,
          kind: FeedTransactionKind.purchase,
          quantity: 50,
          occurredOn: _today,
        ),
      );
      await repo.deleteFeedItem(_domainItem(item));

      final txs = await (db.select(db.feedTransactions)
            ..where((t) => t.feedItemId.equals(item.id)))
          .get();
      expect(txs, hasLength(1));
    });

    test('deleted item does not appear in watchFeedItems', () async {
      final item = await addItem();
      await repo.deleteFeedItem(_domainItem(item));

      final visible = await repo
          .watchFeedItems(_farmId)
          .first;
      expect(visible.where((r) => r.id == item.id), isEmpty);
    });
  });

  group('outbox ordering', () {
    test('item outbox row is inserted before transaction outbox row', () async {
      final item = await addItem();
      await repo.recordTransaction(
        farmId: _farmId,
        input: FeedTransactionInput(
          feedItemId: item.id,
          kind: FeedTransactionKind.purchase,
          quantity: 10,
          occurredOn: _today,
        ),
      );
      final rows = await (db.select(db.outbox)
            ..orderBy([(o) => OrderingTerm(expression: o.opId)]))
          .get();
      // The first row should be the item, the second the transaction.
      final tables = rows.map((r) => r.targetTable).toList();
      expect(tables.indexOf('feed_items'),
          lessThan(tables.indexOf('feed_transactions')));
    });
  });
}

/// Convert a [FeedItemRow] to a [FeedItem] domain object for repository calls.
FeedItem _domainItem(FeedItemRow row) => FeedItem(
      id: row.id,
      farmId: row.farmId,
      name: row.name,
      feedType: row.feedType,
      unit: row.unit,
      reorderLevel: row.reorderLevel,
    );
