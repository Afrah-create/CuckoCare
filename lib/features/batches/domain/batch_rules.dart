import 'package:intl/intl.dart';

import 'batch_facts.dart';
import 'batch_metrics.dart';
import 'calendar_date.dart';
import 'hatch_date.dart';
import 'loss_record.dart';

enum RuleField {
  count,
  occurredOn,
  initialCount,
  acquiredOn,
  ageAtAcquisition,
  closedOn,
  closeReason,
  batch,
}

class RuleViolation {
  const RuleViolation(this.field, this.message);

  final RuleField field;
  final String message;

  @override
  String toString() => message;
}

String _count(int n) => NumberFormat.decimalPattern().format(n);

String _day(CalendarDate d) =>
    DateFormat('d MMM yyyy').format(DateTime(d.year, d.month, d.day));

abstract final class LossRules {
  static const closedMessage =
      'This batch is closed. Reopen it to record losses.';

  /// Checks a new loss, or an edit when [replacing] is the record being changed.
  static RuleViolation? check({
    required BatchFacts batch,
    required BatchMetrics metrics,
    required int count,
    required CalendarDate occurredOn,
    required CalendarDate today,
    LossEntry? replacing,
  }) {
    if (batch.isClosed) {
      return const RuleViolation(RuleField.batch, closedMessage);
    }
    if (count < 1) {
      return const RuleViolation(RuleField.count, 'Enter at least 1 bird.');
    }
    if (occurredOn.compareTo(batch.acquiredOn) < 0) {
      return RuleViolation(
        RuleField.occurredOn,
        "The date can't be before the batch arrived on ${_day(batch.acquiredOn)}.",
      );
    }
    if (occurredOn.compareTo(today) > 0) {
      return const RuleViolation(
        RuleField.occurredOn,
        "The date can't be in the future.",
      );
    }
    final available = maxCount(metrics: metrics, replacing: replacing);
    if (count > available) {
      if (available <= 0) {
        return const RuleViolation(
          RuleField.count,
          'There are no live birds left in this batch.',
        );
      }
      return RuleViolation(
        RuleField.count,
        'You only have ${_count(available)} live birds. '
        'You can record up to ${_count(available)}.',
      );
    }
    return null;
  }

  /// Most birds this record may hold so total losses stay within the placed count.
  static int maxCount({required BatchMetrics metrics, LossEntry? replacing}) {
    return metrics.liveAfter(-(replacing?.count ?? 0));
  }
}

abstract final class BatchRules {
  static const closedReadOnly =
      'This batch is closed. Reopen it to make changes.';

  static RuleViolation? checkInitialCount({
    required int initialCount,
    required int totalLosses,
  }) {
    if (initialCount < 1) {
      return const RuleViolation(
        RuleField.initialCount,
        'Enter at least 1 bird.',
      );
    }
    if (initialCount < totalLosses) {
      return RuleViolation(
        RuleField.initialCount,
        'You have recorded ${_count(totalLosses)} lost birds. '
        'Birds placed must be at least ${_count(totalLosses)}.',
      );
    }
    return null;
  }

  static RuleViolation? checkDates({
    required CalendarDate acquiredOn,
    required int ageAtAcquisitionDays,
    required CalendarDate today,
    CalendarDate? earliestLossOn,
  }) {
    if (acquiredOn.compareTo(today) > 0) {
      return const RuleViolation(
        RuleField.acquiredOn,
        "The arrival date can't be in the future.",
      );
    }
    if (earliestLossOn != null && acquiredOn.compareTo(earliestLossOn) > 0) {
      return RuleViolation(
        RuleField.acquiredOn,
        "The arrival date can't be after the first recorded loss on ${_day(earliestLossOn)}.",
      );
    }
    if (ageAtAcquisitionDays < 1) {
      return const RuleViolation(
        RuleField.ageAtAcquisition,
        'Age at arrival must be at least 1 day.',
      );
    }
    return null;
  }

  static RuleViolation? checkClose({
    required BatchFacts batch,
    required CalendarDate closedOn,
    required CloseReason? reason,
    required CalendarDate today,
    CalendarDate? lastLossOn,
  }) {
    if (batch.isClosed) {
      return const RuleViolation(
        RuleField.batch,
        'This batch is already closed.',
      );
    }
    if (reason == null) {
      return const RuleViolation(
        RuleField.closeReason,
        'Choose why you are closing this batch.',
      );
    }
    if (closedOn.compareTo(batch.acquiredOn) < 0) {
      return RuleViolation(
        RuleField.closedOn,
        "The close date can't be before the batch arrived on ${_day(batch.acquiredOn)}.",
      );
    }
    if (closedOn.compareTo(today) > 0) {
      return const RuleViolation(
        RuleField.closedOn,
        "The close date can't be in the future.",
      );
    }
    if (lastLossOn != null && closedOn.compareTo(lastLossOn) < 0) {
      return RuleViolation(
        RuleField.closedOn,
        "The close date can't be before the last recorded loss on ${_day(lastLossOn)}.",
      );
    }
    return null;
  }

  /// Days every pending task moves when arrival date or age changes.
  static int scheduleShiftDays({
    required BatchFacts before,
    required CalendarDate acquiredOn,
    required int ageAtAcquisitionDays,
  }) {
    final newHatch = hatchDate(
      acquiredOn: acquiredOn,
      ageAtAcquisitionDays: ageAtAcquisitionDays < 1 ? 1 : ageAtAcquisitionDays,
    );
    return before.hatchedOn.daysUntil(newHatch);
  }
}
