import 'calendar_date.dart';
import 'hatch_date.dart';

enum BatchStatus {
  active('active'),
  closed('closed');

  const BatchStatus(this.storage);

  final String storage;

  static BatchStatus fromStorage(String value) =>
      value == 'closed' ? BatchStatus.closed : BatchStatus.active;
}

enum CloseReason {
  sold('sold'),
  cycleComplete('cycle_complete'),
  flockLost('flock_lost'),
  other('other');

  const CloseReason(this.storage);

  final String storage;

  static CloseReason? fromStorage(String? value) {
    if (value == null) {
      return null;
    }
    for (final reason in CloseReason.values) {
      if (reason.storage == value) {
        return reason;
      }
    }
    return null;
  }
}

/// The parts of a batch that metrics and rules need.
class BatchFacts {
  const BatchFacts({
    required this.id,
    required this.initialCount,
    required this.acquiredOn,
    required this.ageAtAcquisitionDays,
    this.status = BatchStatus.active,
    this.closedOn,
  });

  final String id;
  final int initialCount;
  final CalendarDate acquiredOn;
  final int ageAtAcquisitionDays;
  final BatchStatus status;
  final CalendarDate? closedOn;

  bool get isClosed => status == BatchStatus.closed;

  CalendarDate get hatchedOn => hatchDate(
    acquiredOn: acquiredOn,
    ageAtAcquisitionDays: ageAtAcquisitionDays < 1 ? 1 : ageAtAcquisitionDays,
  );
}
