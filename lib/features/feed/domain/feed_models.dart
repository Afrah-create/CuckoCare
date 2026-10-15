// Pure-Dart domain models for feed management.
// No Flutter, Drift, or Supabase imports.

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

  /// Signed multiplier for stock arithmetic.
  /// purchase=+1, adjustment=+1 (quantity may be negative for downward correction),
  /// consumption=-1, wastage=-1.
  int get stockSign => switch (this) {
        purchase => 1,
        adjustment => 1,
        consumption => -1,
        wastage => -1,
      };

  /// Positive kinds add to stock; negative kinds reduce it.
  @Deprecated('Use stockSign > 0 instead')
  bool get isPositive => stockSign > 0;
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

  /// The signed quantity stored on this transaction.
  /// For purchases and consumptions this is always positive (the sign comes
  /// from [FeedTransactionKind.stockSign]).  For adjustments the quantity
  /// itself may be negative (downward correction) or positive (upward
  /// correction); [FeedTransactionKind.stockSign] for adjustment is +1 so
  /// the raw value is used as-is in [FeedMetrics.compute].
  final double quantity;
  final DateTime occurredOn;
  final String? batchId;
  final double? unitCost;
}

// ── FeedMetrics ───────────────────────────────────────────────────────────────

/// Derived stock metrics for a feed item, computed from the transaction ledger.
///
/// Architecture rule 6: never stored — always computed at read time.
class FeedMetrics {
  const FeedMetrics._({
    required this.feedItem,
    required this.rawQuantity,
    required this.recentTransactions,
    required this.totalPurchased,
    required this.totalConsumed,
    required this.totalWasted,
    required this.totalAdjustment,
    required this.totalCost,
  });

  /// Computes [FeedMetrics] from a [FeedItem] and its non-deleted transactions.
  ///
  /// Callers are responsible for filtering out deleted rows before calling
  /// this factory; nothing is excluded here.
  factory FeedMetrics.compute(
    FeedItem item,
    List<FeedTransaction> transactions,
  ) {
    var purchased = 0.0;
    var consumed = 0.0;
    var wasted = 0.0;
    var adjustment = 0.0;
    var cost = 0.0;

    for (final tx in transactions) {
      switch (tx.kind) {
        case FeedTransactionKind.purchase:
          purchased += tx.quantity;
          if (tx.unitCost != null) {
            cost += tx.quantity * tx.unitCost!;
          }
        case FeedTransactionKind.consumption:
          consumed += tx.quantity;
        case FeedTransactionKind.wastage:
          wasted += tx.quantity;
        case FeedTransactionKind.adjustment:
          // quantity may be positive or negative
          adjustment += tx.quantity;
      }
    }

    // net = purchases − consumption − wastage + signed-adjustment
    final raw = purchased - consumed - wasted + adjustment;

    return FeedMetrics._(
      feedItem: item,
      rawQuantity: raw,
      recentTransactions: transactions,
      totalPurchased: purchased,
      totalConsumed: consumed,
      totalWasted: wasted,
      totalAdjustment: adjustment,
      totalCost: cost,
    );
  }

  final FeedItem feedItem;

  /// Raw net quantity — may be negative when ledger is inconsistent.
  final double rawQuantity;

  /// Clamped to 0 for display purposes; use [rawQuantity] for audit.
  double get currentQuantity => rawQuantity < 0 ? 0 : rawQuantity;

  /// All transactions passed to [FeedMetrics.compute].
  final List<FeedTransaction> recentTransactions;

  final double totalPurchased;
  final double totalConsumed;
  final double totalWasted;

  /// Net adjustment (sum of signed adjustment quantities).
  final double totalAdjustment;
  final double totalCost;

  /// True when the ledger implies a negative stock level.
  bool get isInconsistent => rawQuantity < 0;

  bool get belowReorderLevel {
    final level = feedItem.reorderLevel;
    if (level == null) return false;
    return currentQuantity <= level;
  }

  bool get isOutOfStock => currentQuantity <= 0;

  // Keep legacy name for older callers during transition.
  bool get isBelowReorderLevel => belowReorderLevel;
}

/// Backward-compatibility alias so callers that used [FeedStock] continue
/// to compile without changes while the codebase migrates to [FeedMetrics].
typedef FeedStock = FeedMetrics;

// ── Input types ───────────────────────────────────────────────────────────────

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
