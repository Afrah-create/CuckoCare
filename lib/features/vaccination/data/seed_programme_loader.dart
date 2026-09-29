import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import '../../../core/time/clock.dart';
import '../../../data_platform/db/app_database.dart';
class SeedProgrammeLoader {
  SeedProgrammeLoader(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  static const _assetPath =
      'assets/seed/uganda_poultry_vaccination_schedule.json';
  static const _referenceFarmId = 'global';

  Future<void> loadIfEmpty() async {
    final existing = await _db.select(_db.programmes).get();
    if (existing.isNotEmpty) {
      return;
    }

    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final programmes = (json['programmes'] as List<dynamic>).cast<Map>();

    final now = _clock.now();
    await _db.transaction(() async {
      for (final p in programmes) {
        final programmeId = p['id'] as String;
        await _db.into(_db.programmes).insert(
              ProgrammesCompanion.insert(
                id: programmeId,
                farmId: _referenceFarmId,
                createdAt: now,
                updatedAt: now,
                name: p['name'] as String,
                version: p['version'] as int,
                birdTypesJson: jsonEncode(p['bird_types']),
              ),
            );

        final steps = (p['steps'] as List<dynamic>).cast<Map>();
        for (final s in steps) {
          await _db.into(_db.programmeSteps).insert(
                ProgrammeStepsCompanion.insert(
                  id: s['id'] as String,
                  farmId: _referenceFarmId,
                  createdAt: now,
                  updatedAt: now,
                  programmeId: programmeId,
                  name: s['name'] as String,
                  ageDays: s['age_days'] as int,
                  location: s['location'] as String,
                  optional: Value(s['optional'] as bool? ?? false),
                  dueWindowDaysBefore:
                      Value(s['due_window_days_before'] as int? ?? 0),
                  dueWindowDaysAfter:
                      Value(s['due_window_days_after'] as int? ?? 0),
                  recurringJson: Value(
                    s['recurring'] == null
                        ? null
                        : jsonEncode(s['recurring']),
                  ),
                ),
              );
        }
      }
    });
  }
}
