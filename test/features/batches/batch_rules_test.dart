import 'package:cucocare/features/batches/domain/batch_facts.dart';
import 'package:cucocare/features/batches/domain/batch_metrics.dart';
import 'package:cucocare/features/batches/domain/batch_permissions.dart';
import 'package:cucocare/features/batches/domain/batch_rules.dart';
import 'package:cucocare/features/batches/domain/calendar_date.dart';
import 'package:cucocare/features/batches/domain/loss_record.dart';
import 'package:flutter_test/flutter_test.dart';

const today = CalendarDate(year: 2026, month: 3, day: 20);
const arrived = CalendarDate(year: 2026, month: 3, day: 1);

BatchFacts facts({BatchStatus status = BatchStatus.active}) => BatchFacts(
  id: 'b1',
  initialCount: 10,
  acquiredOn: arrived,
  ageAtAcquisitionDays: 1,
  status: status,
);

BatchMetrics metricsWith(int lost) => BatchMetrics.compute(facts(), [
  if (lost > 0)
    LossTally(kind: LossKind.died, occurredOn: arrived, count: lost),
], today);

RuleViolation? checkLoss({
  int count = 1,
  CalendarDate occurredOn = today,
  int lost = 0,
  BatchStatus status = BatchStatus.active,
  LossEntry? replacing,
}) => LossRules.check(
  batch: facts(status: status),
  metrics: metricsWith(lost),
  count: count,
  occurredOn: occurredOn,
  today: today,
  replacing: replacing,
);

void main() {
  group('LossRules', () {
    test('accepts a valid loss', () {
      expect(checkLoss(count: 10), isNull);
    });

    test('rejects closed batches, zero birds, and bad dates', () {
      expect(
        checkLoss(status: BatchStatus.closed)?.message,
        LossRules.closedMessage,
      );
      expect(checkLoss(count: 0)?.field, RuleField.count);
      expect(
        checkLoss(occurredOn: arrived.addDays(-1))?.message,
        "The date can't be before the batch arrived on 1 Mar 2026.",
      );
      expect(
        checkLoss(occurredOn: today.addDays(1))?.message,
        "The date can't be in the future.",
      );
    });

    test('caps the count at the live birds', () {
      expect(
        checkLoss(count: 5, lost: 6)?.message,
        'You only have 4 live birds. You can record up to 4.',
      );
      expect(
        checkLoss(lost: 10)?.message,
        'There are no live birds left in this batch.',
      );
    });

    test('an edit may reuse the birds of the record it replaces', () {
      final existing = LossEntry(
        id: 'l1',
        batchId: 'b1',
        count: 6,
        kind: LossKind.died,
        occurredOn: arrived,
        createdAt: DateTime.utc(2026, 3, 1),
      );
      expect(checkLoss(count: 10, lost: 6, replacing: existing), isNull);
      expect(
        LossRules.maxCount(metrics: metricsWith(6), replacing: existing),
        10,
      );
    });
  });

  group('BatchRules', () {
    test('initial count cannot drop below recorded losses', () {
      expect(
        BatchRules.checkInitialCount(initialCount: 3, totalLosses: 4)?.field,
        RuleField.initialCount,
      );
      expect(
        BatchRules.checkInitialCount(initialCount: 4, totalLosses: 4),
        isNull,
      );
      expect(
        BatchRules.checkInitialCount(initialCount: 0, totalLosses: 0),
        isNotNull,
      );
    });

    test('arrival date cannot be in the future or after the first loss', () {
      expect(
        BatchRules.checkDates(
          acquiredOn: today.addDays(1),
          ageAtAcquisitionDays: 1,
          today: today,
        )?.field,
        RuleField.acquiredOn,
      );
      expect(
        BatchRules.checkDates(
          acquiredOn: arrived.addDays(3),
          ageAtAcquisitionDays: 1,
          today: today,
          earliestLossOn: arrived.addDays(2),
        )?.field,
        RuleField.acquiredOn,
      );
      expect(
        BatchRules.checkDates(
          acquiredOn: arrived,
          ageAtAcquisitionDays: 0,
          today: today,
        )?.field,
        RuleField.ageAtAcquisition,
      );
    });

    test('close needs a reason and a date after the last loss', () {
      RuleViolation? close({
        CloseReason? reason = CloseReason.sold,
        CalendarDate on = today,
        CalendarDate? lastLossOn,
        BatchStatus status = BatchStatus.active,
      }) => BatchRules.checkClose(
        batch: facts(status: status),
        closedOn: on,
        reason: reason,
        today: today,
        lastLossOn: lastLossOn,
      );

      expect(close(), isNull);
      expect(close(reason: null)?.field, RuleField.closeReason);
      expect(close(status: BatchStatus.closed)?.field, RuleField.batch);
      expect(close(on: today.addDays(1))?.field, RuleField.closedOn);
      expect(close(on: arrived.addDays(-1))?.field, RuleField.closedOn);
      expect(
        close(on: arrived.addDays(2), lastLossOn: arrived.addDays(3))?.field,
        RuleField.closedOn,
      );
    });

    test('schedule shift follows the hatch date', () {
      expect(
        BatchRules.scheduleShiftDays(
          before: facts(),
          acquiredOn: arrived.addDays(2),
          ageAtAcquisitionDays: 1,
        ),
        2,
      );
      expect(
        BatchRules.scheduleShiftDays(
          before: facts(),
          acquiredOn: arrived.addDays(2),
          ageAtAcquisitionDays: 3,
        ),
        0,
      );
    });
  });

  group('BatchPermissions', () {
    test('viewers read only; workers record losses; managers manage', () {
      const viewer = BatchPermissions(FarmRole.viewer);
      const worker = BatchPermissions(FarmRole.worker);
      const manager = BatchPermissions(FarmRole.manager);
      const owner = BatchPermissions(FarmRole.owner);

      expect(viewer.canRecordLosses, isFalse);
      expect(viewer.manageBlockedReason, BatchPermissions.viewerReason);
      expect(worker.canRecordLosses, isTrue);
      expect(worker.canManageBatch, isFalse);
      expect(worker.manageBlockedReason, BatchPermissions.workerReason);
      expect(manager.canManageBatch, isTrue);
      expect(owner.canManageBatch, isTrue);
      expect(FarmRole.fromStorage(null), FarmRole.owner);
    });
  });
}
