import 'batch_facts.dart';
import 'calendar_date.dart';
import 'hatch_date.dart';
import 'loss_record.dart';

/// Every bird count and rate shown in the app comes from here.
///
/// The live count is never stored: it is derived from the initial count and
/// the non-deleted loss records, so devices that merge losses agree.
class BatchMetrics {
  const BatchMetrics._({
    required this.initialCount,
    required this.totalLosses,
    required this.diedCount,
    required this.culledCount,
    required this.missingCount,
    required this.otherCount,
    required this.lossesToday,
    required this.losses7d,
    required this.lastLossOn,
    required this.ageDays,
    required this.dailyLosses,
  });

  static const sparklineDays = 14;

  factory BatchMetrics.compute(
    BatchFacts batch,
    Iterable<LossTally> losses,
    CalendarDate today,
  ) {
    var died = 0;
    var culled = 0;
    var missing = 0;
    var other = 0;
    var todayCount = 0;
    var weekCount = 0;
    CalendarDate? last;
    final daily = List<int>.filled(sparklineDays, 0);
    final sparkStart = today.addDays(-(sparklineDays - 1));
    final weekStart = today.addDays(-6);

    for (final loss in losses) {
      if (loss.count <= 0) {
        continue;
      }
      switch (loss.kind) {
        case LossKind.died:
          died += loss.count;
        case LossKind.culled:
          culled += loss.count;
        case LossKind.missing:
          missing += loss.count;
        case LossKind.other:
          other += loss.count;
      }
      final day = loss.occurredOn;
      if (day == today) {
        todayCount += loss.count;
      }
      if (day.compareTo(weekStart) >= 0 && day.compareTo(today) <= 0) {
        weekCount += loss.count;
      }
      final index = sparkStart.daysUntil(day);
      if (index >= 0 && index < sparklineDays) {
        daily[index] += loss.count;
      }
      if (last == null || day.compareTo(last) > 0) {
        last = day;
      }
    }

    final ageEnd =
        batch.isClosed &&
            batch.closedOn != null &&
            batch.closedOn!.compareTo(today) < 0
        ? batch.closedOn!
        : today;

    return BatchMetrics._(
      initialCount: batch.initialCount < 0 ? 0 : batch.initialCount,
      totalLosses: died + culled + missing + other,
      diedCount: died,
      culledCount: culled,
      missingCount: missing,
      otherCount: other,
      lossesToday: todayCount,
      losses7d: weekCount,
      lastLossOn: last,
      ageDays: ageDaysAt(hatch: batch.hatchedOn, today: ageEnd),
      dailyLosses: List.unmodifiable(daily),
    );
  }

  final int initialCount;
  final int totalLosses;
  final int diedCount;
  final int culledCount;
  final int missingCount;
  final int otherCount;
  final int lossesToday;
  final int losses7d;
  final CalendarDate? lastLossOn;
  final int ageDays;

  /// Oldest first; the last entry is today.
  final List<int> dailyLosses;

  int get liveCount {
    final live = initialCount - totalLosses;
    return live < 0 ? 0 : live;
  }

  bool get isInconsistent => totalLosses > initialCount;

  bool get allLost => initialCount > 0 && liveCount == 0;

  int get ageWeeks => ageDays < 1 ? 0 : ((ageDays - 1) ~/ 7) + 1;

  double get mortalityRatePct => _pct(diedCount);

  double get totalLossRatePct => _pct(totalLosses);

  int get sparklineTotal => dailyLosses.fold(0, (sum, n) => sum + n);

  /// Live count if [delta] more birds were lost (negative to add back).
  int liveAfter(int delta) {
    final live = initialCount - totalLosses - delta;
    return live < 0 ? 0 : live;
  }

  double _pct(int part) {
    if (initialCount <= 0) {
      return 0;
    }
    return part / initialCount * 100;
  }

  /// Oldest first, with the running live count after each record.
  static List<LedgerLine> ledger({
    required int initialCount,
    required Iterable<LossEntry> entries,
  }) {
    final sorted = entries.toList()..sort(compareLossEntries);
    var lost = 0;
    final lines = <LedgerLine>[];
    for (final entry in sorted) {
      lost += entry.count;
      final live = initialCount - lost;
      lines.add(LedgerLine(entry: entry, liveAfter: live < 0 ? 0 : live));
    }
    return lines;
  }
}

class LedgerLine {
  const LedgerLine({required this.entry, required this.liveAfter});

  final LossEntry entry;

  /// Live birds right after this record, never below zero.
  final int liveAfter;
}

/// Stable ledger order: by day, then creation time, then id.
int compareLossEntries(LossEntry a, LossEntry b) {
  final byDay = a.occurredOn.compareTo(b.occurredOn);
  if (byDay != 0) {
    return byDay;
  }
  final byCreated = a.createdAt.compareTo(b.createdAt);
  if (byCreated != 0) {
    return byCreated;
  }
  return a.id.compareTo(b.id);
}
