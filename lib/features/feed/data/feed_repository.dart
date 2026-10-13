import 'package:drift/drift.dart';import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/db/synced_write.dart';
import '../domain/feed_models.dart';
import 'feed_item_synced_table.dart';
import 'feed_transaction_synced_table.dart';

/// Combines a FeedItemRow with its derived stock quantity.
class FeedStockRow {
  const FeedStockRow({
    required this.item,
    required this.currentQuantity,
    required this.lastTransactionOn,
  });

  final FeedItemRow item;

  /// Net quantity on hand, derived from transactions (never stored).
  final double currentQuantity;

  /// Date of the most recent transaction, null if no transactions yet.
  final DateTime? lastTransactionOn;

  bool get isBelowReorderLevel {
    final level = item.reorderLevel;
    if (level == null) return false;
    return currentQuantity <= level;
  }

  bool get isOutOfStock => currentQuantity <= 0;
}

class FeedRepository {
  FeedRepository(
    this._db,
    this._clock, {
    SyncedWrite? syncedWrite,
  }) : _syncedWrite = syncedWrite ?? SyncedWrite(_db);

  final AppDatabase _db;
  final Clock _clock;
  final SyncedWrite _syncedWrite;
  final _itemMapper = FeedItemSyncedTable();
  final _txMapper = FeedTransactionSyncedTable();

  // ── Feed Items ────────────────────────────────────────────────────────────

  /// All non-deleted feed items for the farm, ordered by name.
  Stream<List<FeedItemRow>> watchFeedItems(String farmId) {
    return (_db.select(_db.feedItems)
          ..where((f) => f.farmId.equals(farmId) & f.deletedAt.isNull())
          ..orderBy([(f) => OrderingTerm(expression: f.name)]))
        .watch();
  }

  /// Live stock levels for all items on the farm. Stock is derived from
  /// transactions in Dart — no complex SQL type mapping needed.
  Stream<List<FeedStockRow>> watchStockLevelsCombined(String farmId) {
    final itemsStream = watchFeedItems(farmId);

    return itemsStream.asyncExpand((items) {
      if (items.isEmpty) {
        return Stream.value(const <FeedStockRow>[]);
      }
      return _watchTransactionsForFarm(farmId).map(
        (transactions) => _computeStockRows(items, transactions),
      );
    });
  }

  Stream<List<FeedTransactionRow>> _watchTransactionsForFarm(String farmId) {
    return (_db.select(_db.feedTransactions)
          ..where(
            (t) => t.farmId.equals(farmId) & t.deletedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.occurredOn)]))
        .watch();
  }

  /// Public version used by the Transactions tab provider.
  Stream<List<FeedTransactionRow>> watchAllTransactions(String farmId) =>
      _watchTransactionsForFarm(farmId);

  List<FeedStockRow> _computeStockRows(
    List<FeedItemRow> items,
    List<FeedTransactionRow> transactions,
  ) {
    // Group transactions by feedItemId.
    final byItem = <String, List<FeedTransactionRow>>{};
    for (final tx in transactions) {
      byItem.putIfAbsent(tx.feedItemId, () => []).add(tx);
    }

    return items.map((item) {
      final txs = byItem[item.id] ?? const [];
      var qty = 0.0;
      DateTime? lastOn;
      for (final tx in txs) {
        final kind = FeedTransactionKind.fromStorage(tx.kind);
        if (kind.isPositive) {
          qty += tx.quantity;
        } else {
          qty -= tx.quantity;
        }
        if (lastOn == null || tx.occurredOn.isAfter(lastOn)) {
          lastOn = tx.occurredOn;
        }
      }
      return FeedStockRow(
        item: item,
        currentQuantity: qty,
        lastTransactionOn: lastOn,
      );
    }).toList();
  }

  /// Transactions for a single feed item, newest first.
  Stream<List<FeedTransactionRow>> watchTransactions(String feedItemId) {
    return (_db.select(_db.feedTransactions)
          ..where(
            (t) =>
                t.feedItemId.equals(feedItemId) & t.deletedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.occurredOn)]))
        .watch();
  }

  Future<FeedItemRow?> findFeedItem(String id) {
    return (_db.select(_db.feedItems)
          ..where((f) => f.id.equals(id) & f.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Fetches all items + all their transactions for a farm in one go,
  /// used by the report generator. Not a stream — snapshot at call time.
  Future<FeedReportData> fetchReportData(String farmId) async {
    final items = await (_db.select(_db.feedItems)
          ..where((f) => f.farmId.equals(farmId) & f.deletedAt.isNull())
          ..orderBy([(f) => OrderingTerm(expression: f.name)]))
        .get();

    final transactions = await (_db.select(_db.feedTransactions)
          ..where((t) => t.farmId.equals(farmId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.occurredOn)]))
        .get();

    return FeedReportData(
      items: items,
      transactions: transactions,
      generatedAt: _clock.now(),
    );
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  /// Creates a new feed item. Returns the created row.
  Future<FeedItemRow> addFeedItem({
    required String farmId,
    required FeedItemInput input,
  }) async {
    final now = _clock.now();
    final id = newId();
    final row = FeedItemRow(
      id: id,
      farmId: farmId,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      serverVersion: null,
      name: input.name.trim(),
      feedType: input.feedType,
      unit: input.unit,
      reorderLevel: input.reorderLevel,
    );
    await _syncedWrite.writeSynced(
      writeRow: () => _db.into(_db.feedItems).insert(
            FeedItemsCompanion.insert(
              id: id,
              farmId: farmId,
              createdAt: now,
              updatedAt: now,
              name: row.name,
              feedType: row.feedType,
              unit: row.unit,
              reorderLevel: Value(row.reorderLevel),
            ),
          ),
      table: _itemMapper.tableName,
      rowId: id,
      op: 'upsert',
      payload: _itemMapper.toPayload(row),
    );
    return row;
  }

  /// Updates an existing feed item's catalogue details.
  Future<FeedItemRow> updateFeedItem({
    required FeedItemRow existing,
    required FeedItemInput input,
  }) async {
    final now = _clock.now();
    final updated = existing.copyWith(
      updatedAt: now,
      name: input.name.trim(),
      feedType: input.feedType,
      unit: input.unit,
      reorderLevel: Value(input.reorderLevel),
    );
    await _syncedWrite.writeSynced(
      writeRow: () => _db
          .into(_db.feedItems)
          .insertOnConflictUpdate(updated.toCompanion(false)),
      table: _itemMapper.tableName,
      rowId: updated.id,
      op: 'upsert',
      payload: _itemMapper.toPayload(updated),
    );
    return updated;
  }

  /// Soft-deletes a feed item (sets deletedAt). The transactions remain for
  /// historical stock accuracy.
  Future<void> deleteFeedItem(FeedItemRow existing) async {
    final now = _clock.now();
    final deleted = existing.copyWith(
      updatedAt: now,
      deletedAt: Value(now),
    );
    await _syncedWrite.writeSynced(
      writeRow: () => _db
          .into(_db.feedItems)
          .insertOnConflictUpdate(deleted.toCompanion(false)),
      table: _itemMapper.tableName,
      rowId: deleted.id,
      op: 'upsert',
      payload: _itemMapper.toPayload(deleted),
    );
  }

  /// Records a feed transaction (purchase / consumption / etc.).
  /// Append-only — never updates existing rows (arch rule 6).
  Future<FeedTransactionRow> recordTransaction({
    required String farmId,
    required FeedTransactionInput input,
  }) async {
    _assertValidQuantity(input.quantity);
    final now = _clock.now();
    final id = newId();
    final occurredOnDay = DateTime.utc(
      input.occurredOn.year,
      input.occurredOn.month,
      input.occurredOn.day,
    );
    final row = FeedTransactionRow(
      id: id,
      farmId: farmId,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      serverVersion: null,
      feedItemId: input.feedItemId,
      batchId: input.batchId,
      kind: input.kind.storage,
      quantity: input.quantity,
      unitCost: input.unitCost,
      occurredOn: occurredOnDay,
    );
    await _syncedWrite.writeSynced(
      writeRow: () => _db.into(_db.feedTransactions).insert(
            FeedTransactionsCompanion.insert(
              id: id,
              farmId: farmId,
              createdAt: now,
              updatedAt: now,
              feedItemId: row.feedItemId,
              batchId: Value(row.batchId),
              kind: row.kind,
              quantity: row.quantity,
              unitCost: Value(row.unitCost),
              occurredOn: row.occurredOn,
            ),
          ),
      table: _txMapper.tableName,
      rowId: id,
      op: 'upsert',
      payload: _txMapper.toPayload(row),
    );
    return row;
  }

  static void _assertValidQuantity(double quantity) {
    if (quantity <= 0) {
      throw ArgumentError.value(
        quantity,
        'quantity',
        'Quantity must be greater than zero',
      );
    }
  }
}
