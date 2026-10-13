import 'calendar_date.dart';

/// Why birds left the flock. Selling birds is not a loss; that is a batch close.
enum LossKind {
  died('died'),
  culled('culled'),
  missing('missing'),
  other('other');

  const LossKind(this.storage);

  final String storage;

  static LossKind fromStorage(String? value) => LossKind.values.firstWhere(
    (k) => k.storage == value,
    orElse: () => LossKind.died,
  );
}

/// The farmer's own guess. The app never infers or suggests a cause.
enum SuspectedCause {
  unknown('unknown'),
  diseaseSigns('disease_signs'),
  injury('injury'),
  heatOrCold('heat_or_cold'),
  predator('predator'),
  other('other');

  const SuspectedCause(this.storage);

  final String storage;

  static SuspectedCause? fromStorage(String? value) {
    if (value == null) {
      return null;
    }
    for (final cause in SuspectedCause.values) {
      if (cause.storage == value) {
        return cause;
      }
    }
    return null;
  }
}

/// Birds lost on one day for one kind. Several records on the same day add up.
class LossTally {
  const LossTally({
    required this.kind,
    required this.occurredOn,
    required this.count,
  });

  final LossKind kind;
  final CalendarDate occurredOn;
  final int count;
}

/// One loss record as the domain sees it (no Drift types).
class LossEntry {
  const LossEntry({
    required this.id,
    required this.batchId,
    required this.count,
    required this.kind,
    required this.occurredOn,
    required this.createdAt,
    this.suspectedCause,
    this.notes,
    this.editedAt,
  });

  final String id;
  final String batchId;
  final int count;
  final LossKind kind;
  final SuspectedCause? suspectedCause;
  final CalendarDate occurredOn;
  final DateTime createdAt;
  final String? notes;
  final DateTime? editedAt;

  bool get isEdited => editedAt != null;

  LossTally get tally =>
      LossTally(kind: kind, occurredOn: occurredOn, count: count);
}
