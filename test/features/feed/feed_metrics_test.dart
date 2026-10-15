import 'package:cucocare/features/feed/domain/feed_models.dart';
import 'package:flutter_test/flutter_test.dart';

// Helper factory for a minimal FeedItem.
FeedItem item({double? reorderLevel}) => FeedItem(
      id: 'item-1',
      farmId: 'farm-1',
      name: 'Test Feed',
      feedType: 'starter',
      unit: 'kg',
      reorderLevel: reorderLevel,
    );

FeedTransaction tx({
  required FeedTransactionKind kind,
  required double quantity,
  double? unitCost,
  String id = 'tx-1',
}) =>
    FeedTransaction(
      id: id,
      farmId: 'farm-1',
      feedItemId: 'item-1',
      kind: kind,
      quantity: quantity,
      occurredOn: DateTime.utc(2026, 1, 1),
      unitCost: unitCost,
    );

void main() {
  group('FeedMetrics.compute', () {
    test('purchase adds to stock', () {
      final m = FeedMetrics.compute(item(), [
        tx(kind: FeedTransactionKind.purchase, quantity: 100),
      ]);
      expect(m.rawQuantity, 100);
      expect(m.currentQuantity, 100);
      expect(m.totalPurchased, 100);
      expect(m.isInconsistent, isFalse);
    });

    test('consumption reduces stock', () {
      final m = FeedMetrics.compute(item(), [
        tx(kind: FeedTransactionKind.purchase, quantity: 100),
        tx(kind: FeedTransactionKind.consumption, quantity: 30, id: 'tx-2'),
      ]);
      expect(m.rawQuantity, 70);
      expect(m.totalConsumed, 30);
    });

    test('wastage reduces stock', () {
      final m = FeedMetrics.compute(item(), [
        tx(kind: FeedTransactionKind.purchase, quantity: 50),
        tx(kind: FeedTransactionKind.wastage, quantity: 10, id: 'tx-2'),
      ]);
      expect(m.rawQuantity, 40);
      expect(m.totalWasted, 10);
    });

    test('positive adjustment adds to stock', () {
      final m = FeedMetrics.compute(item(), [
        tx(kind: FeedTransactionKind.purchase, quantity: 50),
        tx(kind: FeedTransactionKind.adjustment, quantity: 5, id: 'tx-2'),
      ]);
      expect(m.rawQuantity, closeTo(55, 1e-9));
      expect(m.totalAdjustment, 5);
    });

    test('negative adjustment reduces stock', () {
      final m = FeedMetrics.compute(item(), [
        tx(kind: FeedTransactionKind.purchase, quantity: 50),
        tx(kind: FeedTransactionKind.adjustment, quantity: -5, id: 'tx-2'),
      ]);
      expect(m.rawQuantity, closeTo(45, 1e-9));
      expect(m.totalAdjustment, -5);
    });

    test('all four kinds together', () {
      final m = FeedMetrics.compute(item(), [
        tx(kind: FeedTransactionKind.purchase, quantity: 100),
        tx(kind: FeedTransactionKind.consumption, quantity: 20, id: 'tx-2'),
        tx(kind: FeedTransactionKind.wastage, quantity: 5, id: 'tx-3'),
        tx(kind: FeedTransactionKind.adjustment, quantity: -3, id: 'tx-4'),
      ]);
      // 100 - 20 - 5 + (-3) = 72
      expect(m.rawQuantity, closeTo(72, 1e-9));
      expect(m.totalPurchased, 100);
      expect(m.totalConsumed, 20);
      expect(m.totalWasted, 5);
      expect(m.totalAdjustment, -3);
    });

    test('isInconsistent is true when rawQuantity < 0', () {
      final m = FeedMetrics.compute(item(), [
        tx(kind: FeedTransactionKind.consumption, quantity: 50),
      ]);
      expect(m.rawQuantity, -50);
      expect(m.isInconsistent, isTrue);
      // currentQuantity is clamped to 0
      expect(m.currentQuantity, 0);
    });

    test('currentQuantity clamps negative raw to 0', () {
      final m = FeedMetrics.compute(item(), [
        tx(kind: FeedTransactionKind.purchase, quantity: 10),
        tx(kind: FeedTransactionKind.consumption, quantity: 30, id: 'tx-2'),
      ]);
      expect(m.rawQuantity, -20);
      expect(m.currentQuantity, 0);
    });

    test('belowReorderLevel when currentQuantity <= reorderLevel', () {
      final m = FeedMetrics.compute(item(reorderLevel: 20), [
        tx(kind: FeedTransactionKind.purchase, quantity: 10),
      ]);
      expect(m.currentQuantity, 10);
      expect(m.belowReorderLevel, isTrue);
      expect(m.isBelowReorderLevel, isTrue);
    });

    test('not belowReorderLevel when above threshold', () {
      final m = FeedMetrics.compute(item(reorderLevel: 5), [
        tx(kind: FeedTransactionKind.purchase, quantity: 10),
      ]);
      expect(m.belowReorderLevel, isFalse);
    });

    test('no reorderLevel means never belowReorderLevel', () {
      final m = FeedMetrics.compute(item(), []);
      expect(m.belowReorderLevel, isFalse);
    });

    test('isOutOfStock when currentQuantity <= 0', () {
      final m = FeedMetrics.compute(item(), []);
      expect(m.isOutOfStock, isTrue);
    });

    test('zero-cost entries do not affect totalCost', () {
      final m = FeedMetrics.compute(item(), [
        tx(kind: FeedTransactionKind.purchase, quantity: 100),
      ]);
      expect(m.totalCost, 0);
    });

    test('totalCost accumulates from purchase unit costs', () {
      final m = FeedMetrics.compute(item(), [
        tx(kind: FeedTransactionKind.purchase, quantity: 10, unitCost: 500),
        tx(
          kind: FeedTransactionKind.purchase,
          quantity: 5,
          unitCost: 600,
          id: 'tx-2',
        ),
      ]);
      expect(m.totalCost, closeTo(10 * 500 + 5 * 600, 1e-9));
    });

    test('empty transactions list gives zero stock', () {
      final m = FeedMetrics.compute(item(), []);
      expect(m.rawQuantity, 0);
      expect(m.currentQuantity, 0);
      expect(m.isInconsistent, isFalse);
      expect(m.isOutOfStock, isTrue);
    });

    test('recentTransactions holds all passed-in transactions', () {
      final txs = [
        tx(kind: FeedTransactionKind.purchase, quantity: 10),
        tx(kind: FeedTransactionKind.consumption, quantity: 2, id: 'tx-2'),
      ];
      final m = FeedMetrics.compute(item(), txs);
      expect(m.recentTransactions, txs);
    });
  });

  group('FeedTransactionKind', () {
    test('stockSign is +1 for purchase and adjustment', () {
      expect(FeedTransactionKind.purchase.stockSign, 1);
      expect(FeedTransactionKind.adjustment.stockSign, 1);
    });

    test('stockSign is -1 for consumption and wastage', () {
      expect(FeedTransactionKind.consumption.stockSign, -1);
      expect(FeedTransactionKind.wastage.stockSign, -1);
    });

    test('deprecated isPositive delegates to stockSign > 0', () {
      // ignore: deprecated_member_use
      expect(FeedTransactionKind.purchase.isPositive, isTrue);
      // ignore: deprecated_member_use
      expect(FeedTransactionKind.consumption.isPositive, isFalse);
    });
  });
}
