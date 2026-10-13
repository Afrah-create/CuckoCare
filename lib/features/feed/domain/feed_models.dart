/// Pure-Dart domain models for feed management.
/// No Flutter, Drift, or Supabase imports.

enum FeedTransactionKind {
  purchase,
  consumption,
  adjustment,
  wastage;

  String get storage => name;

  static FeedTransactionKind fromStorage(String? value) =>
      switch (value) {
        'purchase' => purchase,
        'consumption' => consumption,
        'adjustment' => adjustment,
        'wastage' => wastage,
        _ => consumption,
      };

  String get label => switch (this) {
        purchase => 'Purchase',
        consumption => 'Consumption',
        adjustment => 'Adjustment',
        wastage => 'Wastage',
      };

  /// Positive kinds add to stock; negative kinds reduce it.
  bool get isPositive => this == purchase || this == adjustment;
}

/// Domain representation of a catalogue entry.
class FeedItem {
  const FeedItem({
    required this.id,
    required this.farmId,
    required this.name,
    required this.feedType,
    required this.unit,
    this.reorderLevel,
  });

  final String id;
  final String farmId;
  final String name;
  final String feedType;
  final String unit;
  final double? reorderLevel;
}

/// Domain representation of a single ledger entry.
class FeedTransaction {
  const FeedTransaction({
    required this.id,
    required this.farmId,
    required this.feedItemId,
    required this.kind,
    required this.quantity,
    required this.occurredOn,
    this.batchId,
    this.unitCost,
  });

  final String id;
  final String farmId;
  final String feedItemId;
  final FeedTransactionKind kind;
  final double quantity;
  final DateTime occurredOn;
  final String? batchId;
  final double? unitCost;
}

/// Derived stock level for a feed item, computed from the transaction ledger.
/// Architecture rule 6: never stored — always computed at read time.
class FeedStock {
  const FeedStock({
    required this.feedItem,
    required this.currentQuantity,
    required this.recentTransactions,
  });

  final FeedItem feedItem;

  /// Net quantity on hand (purchases − consumption − wastage + adjustments).
  final double currentQuantity;

  /// Most recent transactions for display in the list.
  final List<FeedTransaction> recentTransactions;

  bool get isBelowReorderLevel {
    final level = feedItem.reorderLevel;
    if (level == null) {
      return false;
    }
    return currentQuantity <= level;
  }

  bool get isOutOfStock => currentQuantity <= 0;
}

/// Input for creating or editing a feed item.
class FeedItemInput {
  const FeedItemInput({
    required this.name,
    required this.feedType,
    required this.unit,
    this.reorderLevel,
  });

  final String name;
  final String feedType;
  final String unit;
  final double? reorderLevel;
}

/// Input for recording a feed transaction.
class FeedTransactionInput {
  const FeedTransactionInput({
    required this.feedItemId,
    required this.kind,
    required this.quantity,
    required this.occurredOn,
    this.batchId,
    this.unitCost,
  });

  final String feedItemId;
  final FeedTransactionKind kind;
  final double quantity;
  final DateTime occurredOn;
  final String? batchId;
  final double? unitCost;
}

/// Known feed type labels for the Uganda poultry context.
abstract final class FeedTypes {
  static const starter = 'starter';
  static const grower = 'grower';
  static const finisher = 'finisher';
  static const layer = 'layer';
  static const chick = 'chick';
  static const custom = 'custom';

  static const all = [starter, grower, finisher, layer, chick, custom];

  static String label(String type) => switch (type) {
        'starter' => 'Starter',
        'grower' => 'Grower',
        'finisher' => 'Finisher',
        'layer' => 'Layer',
        'chick' => 'Chick',
        _ => 'Custom',
      };
}

/// Common feed units.
abstract final class FeedUnits {
  static const kg = 'kg';
  static const g = 'g';
  static const bags50 = '50 kg bags';
  static const bags25 = '25 kg bags';
  static const litre = 'litre';

  static const all = [kg, g, bags50, bags25, litre];
}

// ── Report ────────────────────────────────────────────────────────────────────

/// Snapshot of all feed data for a farm, used to build the downloadable report.
/// Pure-Dart — holds domain models only (no Drift/Flutter imports needed here,
/// but callers pass FeedItemRow / FeedTransactionRow from the data layer).
class FeedReportData {
  const FeedReportData({
    required this.items,
    required this.transactions,
    required this.generatedAt,
  });

  /// All non-deleted feed items on the farm.
  final List<dynamic> items; // FeedItemRow at runtime

  /// All non-deleted transactions, newest first.
  final List<dynamic> transactions; // FeedTransactionRow at runtime

  final DateTime generatedAt;
}
