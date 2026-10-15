import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/db/synced_write.dart';
import '../domain/feed_models.dart';
import 'feed_item_synced_table.dart';
import 'feed_transaction_synced_table.dart';

/// Backward-compatibility alias — callers that reference [FeedStockRow]
/// continue to compile while the codebase migrates to [FeedMetrics].
typedef FeedStockRow = FeedMetrics;

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
  Stream<List<FeedMetrics>> watchStockLevelsCombined(String farmId) {
    final itemsStream = watchFeedItems(farmId);

    return itemsStream.asyncExpand((items) {
      if (items.isEmpty) {
        return Stream.value(const <FeedMetrics>[]);
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

  /// Converts a [FeedItemRow] from Drift into a pure domain [FeedItem].
  FeedItem _rowToItem(FeedItemRow row) => FeedItem(
        id: row.id,
        farmId: row.farmId,
        name: row.name,
        feedType: row.feedType,
        unit: row.unit,
        reorderLevel: row.reorderLevel,
      );

  /// Converts a [FeedTransactionRow] from Drift into a pure domain [FeedTransaction].
  FeedTransaction _rowToTransaction(FeedTransactionRow row) => FeedTransaction(
        id: row.id,
        farmId: row.farmId,
        feedItemId: row.feedItemId,
        kind: FeedTransactionKind.fromStorage(row.kind),
        quantity: row.quantity,
        occurredOn: row.occurredOn,
        batchId: row.batchId,
        unitCost: row.unitCost,
      );

  List<FeedMetrics> _computeStockRows(
    List<FeedItemRow> items,
    List<FeedTransactionRow> transactions,
  ) {
    // Group domain transactions by feedItemId.
    final byItem = <String, List<FeedTransaction>>{};
    for (final tx in transactions) {
      byItem.putIfAbsent(tx.feedItemId, () => []).add(_rowToTransaction(tx));
    }

    return items.map((itemRow) {
      final domainItem = _rowToItem(itemRow);
      final txs = byItem[itemRow.id] ?? const [];
      return FeedMetrics.compute(domainItem, txs);
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
  ///
  /// Accepts a domain [FeedItem]; the row is loaded internally to perform
  /// the update with Drift's copy-with semantics.
  Future<FeedItem> updateFeedItem({
    required FeedItem existing,
    required FeedItemInput input,
  }) async {
    final row = await (_db.select(_db.feedItems)
          ..where((f) => f.id.equals(existing.id)))
        .getSingleOrNull();
    if (row == null) {
      throw StateError('Feed item ${existing.id} not found in local DB');
    }
    final now = _clock.now();
    final updated = row.copyWith(
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
    return _rowToItem(updated);
  }

  /// Soft-deletes a feed item (sets deletedAt). The transactions remain for
  /// historical stock accuracy.
  ///
  /// Accepts a domain [FeedItem]; the row is loaded internally.
  Future<void> deleteFeedItem(FeedItem existing) async {
    final row = await (_db.select(_db.feedItems)
          ..where((f) => f.id.equals(existing.id)))
        .getSingleOrNull();
    if (row == null) return; // already gone — treat as no-op
    final now = _clock.now();
    final deleted = row.copyWith(
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

  // ── Backward-compat: some callers still pass FeedItemRow directly. ────────

  /// Updates an existing feed item using a Drift row reference.
  @Deprecated('Pass FeedItem domain object instead')
  Future<FeedItem> updateFeedItemRow({
    required FeedItemRow existing,
    required FeedItemInput input,
  }) => updateFeedItem(existing: _rowToItem(existing), input: input);

  /// Soft-deletes a feed item using a Drift row reference.
  @Deprecated('Pass FeedItem domain object instead')
  Future<void> deleteFeedItemRow(FeedItemRow existing) =>
      deleteFeedItem(_rowToItem(existing));

  /// Records a feed transaction (purchase / consumption / etc.).
  /// Append-only — never updates existing rows (arch rule 6).
  Future<FeedTransactionRow> recordTransaction({
    required String farmId,
    required FeedTransactionInput input,
  }) async {
    _assertValidQuantity(input.kind, input.quantity);
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

  /// Validates the quantity for a given transaction kind.
  ///
  /// * Adjustments: quantity must be non-zero (positive or negative allowed).
  /// * All other kinds: quantity must be strictly positive.
  static void _assertValidQuantity(FeedTransactionKind kind, double quantity) {
    if (kind == FeedTransactionKind.adjustment) {
      if (quantity == 0) {
        throw ArgumentError.value(
          quantity,
          'quantity',
          'Adjustment quantity must be non-zero',
        );
      }
    } else {
      if (quantity <= 0) {
        throw ArgumentError.value(
          quantity,
          'quantity',
          'Quantity must be greater than zero',
        );
      }
    }
  }
}
