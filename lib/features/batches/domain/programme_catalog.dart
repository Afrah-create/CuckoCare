enum ProgrammeKey { broiler, layer }

enum StepCategory { vaccination, deworming, management }

enum StepPriority { core, recommended, optional }

enum StepLocation { hatchery, farm }

class DueWindowConvention {
  const DueWindowConvention({
    required this.defaultDaysBefore,
    required this.defaultDaysAfterOverdue,
  });

  final int defaultDaysBefore;
  final int defaultDaysAfterOverdue;
}

class ProgrammeStep {
  const ProgrammeStep({
    required this.id,
    required this.ageDays,
    required this.label,
    required this.category,
    required this.priority,
    required this.location,
    required this.diseases,
    required this.vaccineOptions,
    required this.routes,
    required this.sources,
    required this.notes,
  });

  final String id;
  final int ageDays;
  final String label;
  final StepCategory category;
  final StepPriority priority;
  final StepLocation location;
  final List<String> diseases;
  final List<String> vaccineOptions;
  final List<String> routes;
  final List<String> sources;
  final String notes;
}

class RecurringRule {
  const RecurringRule({
    required this.id,
    required this.label,
    required this.category,
    required this.priority,
    required this.startAgeDays,
    required this.intervalDays,
    required this.endAgeDays,
    required this.diseases,
    required this.alternateIbStrain,
    required this.routes,
    required this.sources,
    required this.notes,
  });

  final String id;
  final String label;
  final StepCategory category;
  final StepPriority priority;
  final int startAgeDays;
  final int intervalDays;
  final int endAgeDays;
  final List<String> diseases;
  final List<String> alternateIbStrain;
  final List<String> routes;
  final List<String> sources;
  final String notes;
}

class Programme {
  const Programme({
    required this.key,
    required this.steps,
    required this.recurring,
    this.typicalCycleDaysMax,
    this.offLayAgeDaysMax,
  });

  final ProgrammeKey key;
  final List<ProgrammeStep> steps;
  final List<RecurringRule> recurring;
  final int? typicalCycleDaysMax;
  final int? offLayAgeDaysMax;
}

class ProgrammeCatalog {
  ProgrammeCatalog({
    required this.schemaVersion,
    required this.name,
    required this.status,
    required this.dueWindow,
    required this.programmes,
    required this.contentHash,
    required this.isDraft,
  });

  final int schemaVersion;
  final String name;
  final String status;
  final DueWindowConvention dueWindow;
  final Map<ProgrammeKey, Programme> programmes;
  final String contentHash;
  final bool isDraft;

  Programme? programme(ProgrammeKey key) => programmes[key];

  static const supportedSchemaVersion = 1;

  static ProgrammeCatalog parse(
    Map<String, dynamic> json, {
    required String contentHash,
  }) {
    final schemaVersion = json['schema_version'];
    if (schemaVersion is! int || schemaVersion != supportedSchemaVersion) {
      throw ProgrammeCatalogException(
        'Unsupported schema_version: $schemaVersion (expected $supportedSchemaVersion)',
      );
    }

    final status = json['status'] as String? ?? '';
    final conventions = json['conventions'] as Map<String, dynamic>? ?? {};
    final dueRaw = conventions['due_window'] as Map<String, dynamic>? ?? {};
    final dueWindow = DueWindowConvention(
      defaultDaysBefore: dueRaw['default_days_before'] as int? ?? 1,
      defaultDaysAfterOverdue:
          dueRaw['default_days_after_overdue'] as int? ?? 3,
    );

    final programs = json['programs'] as Map<String, dynamic>? ?? {};
    final programmes = <ProgrammeKey, Programme>{};

    for (final entry in ProgrammeKey.values) {
      final keyName = entry.name;
      final raw = programs[keyName] as Map<String, dynamic>?;
      if (raw == null) {
        continue;
      }
      programmes[entry] = _parseProgramme(entry, raw);
    }

    if (programmes.isEmpty) {
      throw ProgrammeCatalogException('No programs found in schedule file');
    }

    _validateUniqueStepIds(programmes);

    return ProgrammeCatalog(
      schemaVersion: schemaVersion,
      name: json['name'] as String? ?? '',
      status: status,
      dueWindow: dueWindow,
      programmes: programmes,
      contentHash: contentHash,
      isDraft: status.trimLeft().toUpperCase().startsWith('DRAFT'),
    );
  }

  static Programme _parseProgramme(ProgrammeKey key, Map<String, dynamic> raw) {
    final stepsRaw = (raw['steps'] as List<dynamic>? ?? []).cast<Map>();
    final steps = <ProgrammeStep>[];
    for (final s in stepsRaw) {
      steps.add(_parseStep(s));
    }

    final recurringRaw = (raw['recurring'] as List<dynamic>? ?? []).cast<Map>();
    final recurring = <RecurringRule>[];
    for (final r in recurringRaw) {
      recurring.add(_parseRecurring(r));
    }

    return Programme(
      key: key,
      steps: steps,
      recurring: recurring,
      typicalCycleDaysMax: _parseRangeMax(raw['typical_cycle_days']),
      offLayAgeDaysMax: _parseRangeMax(raw['off_lay_age_days']),
    );
  }

  static ProgrammeStep _parseStep(Map<dynamic, dynamic> s) {
    final id = s['id'] as String? ?? '';
    final ageDays = s['age_days'];
    if (id.isEmpty) {
      throw ProgrammeCatalogException('Step missing id');
    }
    if (ageDays is! int || ageDays < 1) {
      throw ProgrammeCatalogException('Step $id: invalid age_days');
    }
    return ProgrammeStep(
      id: id,
      ageDays: ageDays,
      label: s['label'] as String? ?? id,
      category: _parseCategory(s['category'] as String?, id),
      priority: _parsePriority(s['priority'] as String?, id),
      location: _parseLocation(s['location'] as String?, id),
      diseases: _stringList(s['diseases']),
      vaccineOptions: _stringList(s['vaccine_options']),
      routes: _stringList(s['routes']),
      sources: _stringList(s['sources']),
      notes: s['notes'] as String? ?? '',
    );
  }

  static RecurringRule _parseRecurring(Map<dynamic, dynamic> r) {
    final id = r['id'] as String? ?? '';
    final start = r['start_age_days'];
    final end = r['end_age_days'];
    final interval = r['interval_days'];
    if (id.isEmpty) {
      throw ProgrammeCatalogException('Recurring rule missing id');
    }
    if (start is! int || end is! int || interval is! int) {
      throw ProgrammeCatalogException('Recurring $id: invalid age or interval');
    }
    if (start >= end || interval < 1) {
      throw ProgrammeCatalogException(
        'Recurring $id: start/end/interval invalid',
      );
    }
    return RecurringRule(
      id: id,
      label: r['label'] as String? ?? id,
      category: _parseCategory(r['category'] as String?, id),
      priority: _parsePriority(r['priority'] as String?, id),
      startAgeDays: start,
      intervalDays: interval,
      endAgeDays: end,
      diseases: _stringList(r['diseases']),
      alternateIbStrain: _stringList(r['alternate_ib_strain']),
      routes: _stringList(r['routes']),
      sources: _stringList(r['sources']),
      notes: r['notes'] as String? ?? '',
    );
  }

  static StepCategory _parseCategory(String? raw, String id) {
    return switch (raw) {
      'vaccination' => StepCategory.vaccination,
      'deworming' => StepCategory.deworming,
      'management' => StepCategory.management,
      _ => throw ProgrammeCatalogException('Step $id: unknown category $raw'),
    };
  }

  static StepPriority _parsePriority(String? raw, String id) {
    return switch (raw) {
      'core' => StepPriority.core,
      'recommended' => StepPriority.recommended,
      'optional' => StepPriority.optional,
      _ => throw ProgrammeCatalogException('Step $id: unknown priority $raw'),
    };
  }

  static StepLocation _parseLocation(String? raw, String id) {
    return switch (raw) {
      'hatchery' => StepLocation.hatchery,
      'farm' => StepLocation.farm,
      _ => throw ProgrammeCatalogException('Step $id: unknown location $raw'),
    };
  }

  static List<String> _stringList(dynamic raw) {
    if (raw == null) {
      return const [];
    }
    return (raw as List<dynamic>).map((e) => e.toString()).toList();
  }

  static int? _parseRangeMax(dynamic raw) {
    if (raw == null) {
      return null;
    }
    final s = raw.toString();
    final parts = s.split('-');
    final last = parts.last.trim();
    return int.tryParse(last);
  }

  static void _validateUniqueStepIds(Map<ProgrammeKey, Programme> programmes) {
    final seen = <String>{};
    for (final p in programmes.values) {
      for (final step in p.steps) {
        if (!seen.add(step.id)) {
          throw ProgrammeCatalogException('Duplicate step id ${step.id}');
        }
      }
      for (final rule in p.recurring) {
        if (!seen.add(rule.id)) {
          throw ProgrammeCatalogException('Duplicate step id ${rule.id}');
        }
      }
    }
  }
}

class ProgrammeCatalogException implements Exception {
  ProgrammeCatalogException(this.message);
  final String message;

  @override
  String toString() => 'ProgrammeCatalogException: $message';
}
