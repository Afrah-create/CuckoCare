import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'calendar_date.dart';
import 'collision_policy.dart';
import 'hatch_date.dart';
import 'programme_catalog.dart';
import 'programme_resolver.dart';

/// Namespace for deterministic task ids (UUID v5).
const batchTaskIdNamespace = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';

enum PlannedTaskStatus { pending, done, skipped, assumedDone }

enum HatcheryVaccinationAnswer { yes, no, notSure }

class BatchPlanOptions {
  const BatchPlanOptions({
    this.includeRecommended = true,
    this.includeOptional = false,
    this.hatcheryAnswer = HatcheryVaccinationAnswer.notSure,
    this.recurringHorizonDays = 180,
    this.collisionPolicy = const CollisionPolicy(),
    this.stepEnabledOverrides = const {},
  });

  final bool includeRecommended;
  final bool includeOptional;
  final HatcheryVaccinationAnswer hatcheryAnswer;
  final int recurringHorizonDays;
  final CollisionPolicy collisionPolicy;

  /// Per [stepId] enabled flag from the review customise step.
  final Map<String, bool> stepEnabledOverrides;
}

class BatchPlanInput {
  const BatchPlanInput({
    required this.batchId,
    required this.farmId,
    required this.name,
    required this.birdType,
    required this.initialCount,
    required this.acquiredOn,
    required this.ageAtAcquisitionDays,
    this.productionType,
    this.sourceName,
    this.notes,
  });

  final String batchId;
  final String farmId;
  final String name;
  final BirdType birdType;
  final int initialCount;
  final CalendarDate acquiredOn;
  final int ageAtAcquisitionDays;
  final ProductionType? productionType;
  final String? sourceName;
  final String? notes;
}

class PlannedTask {
  const PlannedTask({
    required this.id,
    required this.stepId,
    required this.occurrence,
    required this.dueOn,
    required this.originalDueOn,
    required this.status,
    required this.enabled,
    required this.category,
    required this.location,
    required this.stepSnapshotJson,
  });

  final String id;
  final String stepId;
  final int occurrence;
  final CalendarDate dueOn;
  final CalendarDate originalDueOn;
  final PlannedTaskStatus status;
  final bool enabled;
  final StepCategory category;
  final StepLocation location;
  final String stepSnapshotJson;

  CalendarDate? get shiftedFrom =>
      dueOn == originalDueOn ? null : originalDueOn;
}

class BatchPlanWarning {
  const BatchPlanWarning(this.code, this.message);
  final String code;
  final String message;
}

class BatchPlan {
  const BatchPlan({
    required this.programmeKey,
    required this.hatchDate,
    required this.tasks,
    required this.warnings,
  });

  final ProgrammeKey? programmeKey;
  final CalendarDate hatchDate;
  final List<PlannedTask> tasks;
  final List<BatchPlanWarning> warnings;
}

class BatchPlanner {
  const BatchPlanner({this.resolver = const ProgrammeResolver()});

  final ProgrammeResolver resolver;

  BatchPlan plan({
    required BatchPlanInput input,
    required ProgrammeCatalog catalog,
    required BatchPlanOptions options,
    required CalendarDate today,
  }) {
    final warnings = <BatchPlanWarning>[];
    final hatch = hatchDate(
      acquiredOn: input.acquiredOn,
      ageAtAcquisitionDays: input.ageAtAcquisitionDays,
    );

    final programmeKey = resolver.resolve(
      birdType: input.birdType,
      productionType: input.productionType,
    );

    if (programmeKey == null) {
      return BatchPlan(
        programmeKey: null,
        hatchDate: hatch,
        tasks: const [],
        warnings: [
          const BatchPlanWarning(
            'no_programme',
            'No vaccination schedule for this bird type yet.',
          ),
        ],
      );
    }

    final programme = catalog.programme(programmeKey)!;
    _ageWarnings(programme, input.ageAtAcquisitionDays, warnings);

    final drafts = <_DraftTask>[];

    for (final step in programme.steps) {
      if (step.priority == StepPriority.core) {
        // always materialised
      } else if (step.priority == StepPriority.recommended &&
          !options.includeRecommended &&
          !options.stepEnabledOverrides.containsKey(step.id)) {
        continue;
      }

      final defaultEnabled = _defaultEnabled(step.priority, options);
      final enabled = options.stepEnabledOverrides[step.id] ?? defaultEnabled;

      drafts.add(
        _draftFromStep(
          input: input,
          hatch: hatch,
          step: step,
          options: options,
          today: today,
          enabled: enabled,
        ),
      );
    }

    drafts.addAll(
      _recurringDrafts(
        input: input,
        hatch: hatch,
        programme: programme,
        options: options,
        today: today,
        catalog: catalog,
        programmeKey: programmeKey,
      ),
    );

    final withCollisions = _applyCollisions(drafts, options.collisionPolicy);

    final tasks = withCollisions
        .map(
          (d) => PlannedTask(
            id: _taskId(input.batchId, d.stepId, d.occurrence),
            stepId: d.stepId,
            occurrence: d.occurrence,
            dueOn: d.dueOn,
            originalDueOn: d.originalDueOn,
            status: d.status,
            enabled: d.enabled,
            category: d.category,
            location: d.location,
            stepSnapshotJson: d.snapshotJson,
          ),
        )
        .toList()
      ..sort((a, b) => a.dueOn.compareTo(b.dueOn));

    return BatchPlan(
      programmeKey: programmeKey,
      hatchDate: hatch,
      tasks: tasks,
      warnings: warnings,
    );
  }

  void _ageWarnings(
    Programme programme,
    int age,
    List<BatchPlanWarning> warnings,
  ) {
    final maxCycle = programme.typicalCycleDaysMax;
    if (maxCycle != null && age > maxCycle) {
      warnings.add(
        BatchPlanWarning(
          'old_broiler',
          'Birds are older than typical broiler cycle ($maxCycle days).',
        ),
      );
    }
    final maxLay = programme.offLayAgeDaysMax;
    if (maxLay != null && age > maxLay) {
      warnings.add(
        BatchPlanWarning(
          'old_layer',
          'Birds are older than typical layer cycle ($maxLay days).',
        ),
      );
    }
  }

  bool _includeStep(StepPriority priority, BatchPlanOptions options) {
    return switch (priority) {
      StepPriority.core => true,
      StepPriority.recommended => options.includeRecommended,
      StepPriority.optional => options.includeOptional,
    };
  }

  bool _defaultEnabled(StepPriority priority, BatchPlanOptions options) {
    return switch (priority) {
      StepPriority.core => true,
      StepPriority.recommended => options.includeRecommended,
      StepPriority.optional => options.includeOptional,
    };
  }

  _DraftTask _draftFromStep({
    required BatchPlanInput input,
    required CalendarDate hatch,
    required ProgrammeStep step,
    required BatchPlanOptions options,
    required CalendarDate today,
    required bool enabled,
  }) {
    final originalDue = hatch.addDays(step.ageDays - 1);
    final status = _statusForStep(
      step: step,
      ageAtAcquisition: input.ageAtAcquisitionDays,
      options: options,
      hatch: hatch,
    );

    return _DraftTask(
      stepId: step.id,
      occurrence: 0,
      originalDueOn: originalDue,
      dueOn: originalDue,
      status: status,
      enabled: enabled,
      category: step.category,
      location: step.location,
      snapshotJson: _snapshotForStep(step, programmeKey: null),
    );
  }

  List<_DraftTask> _recurringDrafts({
    required BatchPlanInput input,
    required CalendarDate hatch,
    required Programme programme,
    required BatchPlanOptions options,
    required CalendarDate today,
    required ProgrammeCatalog catalog,
    required ProgrammeKey programmeKey,
  }) {
    final out = <_DraftTask>[];
    final horizonEnd = today.addDays(options.recurringHorizonDays);

    for (final rule in programme.recurring) {
      if (!_includeStep(rule.priority, options)) {
        continue;
      }

      var occurrence = 0;
      var age = rule.startAgeDays;
      String? lastIbStrain;

      for (final step in programme.steps) {
        if (step.ageDays < rule.startAgeDays &&
            step.diseases.any((d) => d.contains('Bronchitis'))) {
          for (final opt in step.vaccineOptions) {
            if (opt.contains('Ma5')) {
              lastIbStrain = rule.alternateIbStrain.isNotEmpty
                  ? rule.alternateIbStrain.first
                  : 'Ma5 (classic IB)';
            } else if (opt.contains('4/91')) {
              lastIbStrain = rule.alternateIbStrain.length > 1
                  ? rule.alternateIbStrain[1]
                  : 'IB 4/91 (variant)';
            }
          }
        }
      }

      while (age <= rule.endAgeDays) {
        if (age >= input.ageAtAcquisitionDays) {
          final due = hatch.addDays(age - 1);
          if (!due.isAfter(horizonEnd)) {
            String? chosenStrain;
            final strains = rule.alternateIbStrain;
            if (strains.length >= 2) {
              final startIndex = lastIbStrain == strains[0] ? 1 : 0;
              chosenStrain = strains[(startIndex + occurrence) % strains.length];
            }

            out.add(
              _DraftTask(
                stepId: rule.id,
                occurrence: occurrence,
                originalDueOn: due,
                dueOn: due,
                status: PlannedTaskStatus.pending,
                enabled: true,
                category: rule.category,
                location: StepLocation.farm,
                snapshotJson: _snapshotForRecurring(
                  rule,
                  programmeKey: programmeKey,
                  chosenStrain: chosenStrain,
                ),
              ),
            );
          }
        }
        occurrence++;
        age = rule.startAgeDays + occurrence * rule.intervalDays;
      }
    }
    return out;
  }

  PlannedTaskStatus _statusForStep({
    required ProgrammeStep step,
    required int ageAtAcquisition,
    required BatchPlanOptions options,
    required CalendarDate hatch,
  }) {
    if (step.location == StepLocation.hatchery) {
      return switch (options.hatcheryAnswer) {
        HatcheryVaccinationAnswer.yes => PlannedTaskStatus.done,
        HatcheryVaccinationAnswer.no => PlannedTaskStatus.skipped,
        HatcheryVaccinationAnswer.notSure => PlannedTaskStatus.assumedDone,
      };
    }

    if (step.ageDays < ageAtAcquisition) {
      return PlannedTaskStatus.assumedDone;
    }

    return PlannedTaskStatus.pending;
  }

  List<_DraftTask> _applyCollisions(
    List<_DraftTask> drafts,
    CollisionPolicy policy,
  ) {
    final vaccinationDates = drafts
        .where((d) => d.category == StepCategory.vaccination)
        .map((d) => (dueOn: d.dueOn, category: d.category));

    final result = <_DraftTask>[];
    for (final d in drafts) {
      if (d.category == StepCategory.vaccination) {
        result.add(d);
        continue;
      }
      final resolved = policy.resolveDueDate(
        proposed: d.originalDueOn,
        category: d.category,
        allTasks: [
          ...vaccinationDates,
          ...result.map((r) => (dueOn: r.dueOn, category: r.category)),
        ],
      );
      result.add(
        _DraftTask(
          stepId: d.stepId,
          occurrence: d.occurrence,
          originalDueOn: d.originalDueOn,
          dueOn: resolved,
          status: d.status,
          enabled: d.enabled,
          category: d.category,
          location: d.location,
          snapshotJson: d.snapshotJson,
        ),
      );
    }
    return result;
  }

  String _taskId(String batchId, String stepId, int occurrence) {
    return const Uuid().v5(
      batchTaskIdNamespace,
      '$batchId:$stepId:$occurrence',
    );
  }

  String _snapshotForStep(ProgrammeStep step, {ProgrammeKey? programmeKey}) {
    return jsonEncode({
      'label': step.label,
      'category': step.category.name,
      'priority': step.priority.name,
      'location': step.location.name,
      'diseases': step.diseases,
      'vaccine_options': step.vaccineOptions,
      'routes': step.routes,
      'sources': step.sources,
      'notes': step.notes,
      if (programmeKey != null) 'programme_key': programmeKey.name,
    });
  }

  String _snapshotForRecurring(
    RecurringRule rule, {
    required ProgrammeKey programmeKey,
    String? chosenStrain,
  }) {
    return jsonEncode({
      'label': rule.label,
      'category': rule.category.name,
      'priority': rule.priority.name,
      'location': 'farm',
      'diseases': rule.diseases,
      'routes': rule.routes,
      'sources': rule.sources,
      'notes': rule.notes,
      'programme_key': programmeKey.name,
      if (chosenStrain != null) 'chosen_ib_strain': chosenStrain,
    });
  }
}

class _DraftTask {
  _DraftTask({
    required this.stepId,
    required this.occurrence,
    required this.originalDueOn,
    required this.dueOn,
    required this.status,
    required this.enabled,
    required this.category,
    required this.location,
    required this.snapshotJson,
  });

  final String stepId;
  final int occurrence;
  final CalendarDate originalDueOn;
  CalendarDate dueOn;
  final PlannedTaskStatus status;
  final bool enabled;
  final StepCategory category;
  final StepLocation location;
  final String snapshotJson;
}

extension on CalendarDate {
  bool isAfter(CalendarDate other) => compareTo(other) > 0;
}
