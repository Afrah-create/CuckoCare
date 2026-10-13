import 'package:cucocare/features/batches/domain/batch_facts.dart';
import 'package:cucocare/features/batches/domain/batch_metrics.dart';
import 'package:cucocare/features/batches/domain/calendar_date.dart';
import 'package:cucocare/features/batches/domain/loss_record.dart';
import 'package:flutter_test/flutter_test.dart';

const today = CalendarDate(year: 2026, month: 3, day: 20);

BatchFacts facts({
  int initialCount = 100,
  BatchStatus status = BatchStatus.active,
  CalendarDate? closedOn,
}) => BatchFacts(
  id: 'b1',
  initialCount: initialCount,
  acquiredOn: const CalendarDate(year: 2026, month: 3, day: 1),
  ageAtAcquisitionDays: 1,
  status: status,
  closedOn: closedOn,
);

LossTally tally(int count, int daysAgo, [LossKind kind = LossKind.died]) =>
    LossTally(kind: kind, occurredOn: today.addDays(-daysAgo), count: count);

LossEntry entry(String id, int count, CalendarDate on, {DateTime? createdAt}) =>
    LossEntry(
      id: id,
      batchId: 'b1',
      count: count,
      kind: LossKind.died,
      occurredOn: on,
      createdAt: createdAt ?? DateTime.utc(2026, 3, 1),
    );

void main() {
  group('BatchMetrics.compute', () {
    test('live count is initial minus every kind of loss', () {
      final m = BatchMetrics.compute(facts(), [
        tally(3, 0),
        tally(2, 1, LossKind.culled),
        tally(1, 2, LossKind.missing),
        tally(4, 3, LossKind.other),
      ], today);

      expect(m.totalLosses, 10);
      expect(m.liveCount, 90);
      expect(m.diedCount, 3);
      expect(m.culledCount, 2);
      expect(m.missingCount, 1);
      expect(m.otherCount, 4);
      expect(m.mortalityRatePct, closeTo(3, 1e-9));
      expect(m.totalLossRatePct, closeTo(10, 1e-9));
    });

    test('several records on the same day add up', () {
      final m = BatchMetrics.compute(facts(), [
        tally(2, 0),
        tally(5, 0),
      ], today);
      expect(m.lossesToday, 7);
      expect(m.dailyLosses.last, 7);
    });

    test('last 7 days and the 14-day sparkline use calendar days', () {
      final m = BatchMetrics.compute(facts(), [
        tally(1, 0),
        tally(2, 6),
        tally(4, 7),
        tally(8, 13),
        tally(16, 14),
      ], today);

      expect(m.losses7d, 3);
      expect(m.dailyLosses, hasLength(BatchMetrics.sparklineDays));
      expect(m.dailyLosses.first, 8);
      expect(m.sparklineTotal, 15);
      expect(m.lastLossOn, today);
    });

    test('never shows a negative live count and flags the inconsistency', () {
      final m = BatchMetrics.compute(facts(initialCount: 5), [
        tally(8, 0),
      ], today);
      expect(m.liveCount, 0);
      expect(m.isInconsistent, isTrue);
      expect(m.allLost, isTrue);
    });

    test('zero placed birds gives zero rates', () {
      final m = BatchMetrics.compute(facts(initialCount: 0), const [], today);
      expect(m.mortalityRatePct, 0);
      expect(m.allLost, isFalse);
    });

    test('age stops on the close date', () {
      final open = BatchMetrics.compute(facts(), const [], today);
      final closed = BatchMetrics.compute(
        facts(
          status: BatchStatus.closed,
          closedOn: const CalendarDate(year: 2026, month: 3, day: 10),
        ),
        const [],
        today,
      );
      expect(closed.ageDays, open.ageDays - 10);
    });

    test('liveAfter previews a change without going below zero', () {
      final m = BatchMetrics.compute(facts(initialCount: 10), [
        tally(4, 0),
      ], today);
      expect(m.liveAfter(3), 3);
      expect(m.liveAfter(-4), 10);
      expect(m.liveAfter(50), 0);
    });
  });

  group('BatchMetrics.ledger', () {
    test('orders by day then creation time and keeps a running count', () {
      final d1 = const CalendarDate(year: 2026, month: 3, day: 5);
      final d2 = const CalendarDate(year: 2026, month: 3, day: 6);
      final lines = BatchMetrics.ledger(
        initialCount: 20,
        entries: [
          entry('c', 4, d2),
          entry('b', 2, d1, createdAt: DateTime.utc(2026, 3, 5, 12)),
          entry('a', 1, d1, createdAt: DateTime.utc(2026, 3, 5, 8)),
        ],
      );

      expect(lines.map((l) => l.entry.id), ['a', 'b', 'c']);
      expect(lines.map((l) => l.liveAfter), [19, 17, 13]);
    });

    test('clamps the running count at zero', () {
      final lines = BatchMetrics.ledger(
        initialCount: 3,
        entries: [entry('a', 5, today)],
      );
      expect(lines.single.liveAfter, 0);
    });
  });
}
