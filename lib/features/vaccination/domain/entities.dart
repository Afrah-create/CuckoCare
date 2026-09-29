enum BirdType { broiler, layer, dualPurpose, local }

enum VaccinationTaskStatus { pending, done, skipped, assumedDone }

enum TaskDisplayState { upcoming, dueToday, overdue, done }

enum StepLocation { hatchery, farm }

class RecurringSchedule {
  const RecurringSchedule({
    required this.intervalDays,
    required this.horizonDays,
  });

  final int intervalDays;
  final int horizonDays;
}

class ProgrammeStep {
  const ProgrammeStep({
    required this.id,
    required this.programmeId,
    required this.name,
    required this.ageDays,
    required this.location,
    required this.optional,
    required this.dueWindowDaysBefore,
    required this.dueWindowDaysAfter,
    this.recurring,
  });

  final String id;
  final String programmeId;
  final String name;
  final int ageDays;
  final StepLocation location;
  final bool optional;
  final int dueWindowDaysBefore;
  final int dueWindowDaysAfter;
  final RecurringSchedule? recurring;
}

class Batch {
  const Batch({
    required this.id,
    required this.farmId,
    required this.acquiredOn,
    required this.ageAtAcquisitionDays,
    required this.programmeId,
    required this.programmeVersion,
    this.hatcheryVaccinated,
  });

  final String id;
  final String farmId;
  final DateTime acquiredOn;
  final int ageAtAcquisitionDays;
  final String programmeId;
  final int programmeVersion;
  final bool? hatcheryVaccinated;
}

class VaccinationTaskDraft {
  const VaccinationTaskDraft({
    required this.stepId,
    required this.dueOn,
    required this.status,
  });

  final String stepId;
  final DateTime dueOn;
  final VaccinationTaskStatus status;
}

class VaccinationTask {
  const VaccinationTask({
    required this.id,
    required this.batchId,
    required this.stepId,
    required this.dueOn,
    required this.status,
  });

  final String id;
  final String batchId;
  final String stepId;
  final DateTime dueOn;
  final VaccinationTaskStatus status;
}
