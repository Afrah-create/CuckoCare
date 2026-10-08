import 'dart:convert';

import 'package:drift/drift.dart';

import '../../features/batches/domain/calendar_date.dart';
import '../../features/farms/domain/farm_profile.dart';
import '../../features/notifications/domain/reminder_planner.dart';
import '../../features/notifications/domain/step_snapshot.dart';
import '../db/app_database.dart';

class ReminderPlanLoader {
  const ReminderPlanLoader();

  Future<ReminderPlanLoadResult> load(AppDatabase db) async {
    final farms = await (db.select(db.farms)
          ..where((f) => f.deletedAt.isNull()))
        .get();
    final farmsById = {for (final farm in farms) farm.id: farm};
    final snapshot = await db.select(db.authSnapshot).getSingleOrNull();
    final primary = selectPrimaryFarm(farms, _snapshotFarmIds(snapshot));

    final batches = await (db.select(db.batches)
          ..where(
            (b) => b.deletedAt.isNull() & b.status.equals('active'),
          ))
        .get();
    final batchById = {for (final b in batches) b.id: b};

    final taskRows = await (db.select(db.vaccinationTasks)
          ..where((t) => t.deletedAt.isNull()))
        .get();

    final tasks = <ReminderPlanTask>[];
    for (final row in taskRows) {
      final batch = batchById[row.batchId];
      if (batch == null) {
        continue;
      }
      final display = farmForReminder(farmsById[row.farmId], primary);
      tasks.add(
        ReminderPlanTask(
          taskId: row.id,
          batchId: row.batchId,
          farmId: row.farmId,
          batchName: batch.name,
          farmName: () {
            final name = display?.name.trim() ?? '';
            return name.isEmpty ? 'Farm' : name;
          }(),
          farmDetail: farmDetailLabel(display),
          stepLabel: stepLabelFromSnapshot(row.stepSnapshot, row.stepId),
          dueOn: CalendarDate.fromDateTime(row.dueOn.toUtc()),
          enabled: row.enabled,
          status: row.status,
          isHatcheryStep: isHatcheryStepSnapshot(row.stepSnapshot),
          batchActive: true,
        ),
      );
    }

    return ReminderPlanLoadResult(
      tasks: tasks,
      farmCount: batches.map((batch) => batch.farmId).toSet().length,
    );
  }
}

List<String> _snapshotFarmIds(AuthSnapshotRow? row) {
  if (row == null) {
    return const [];
  }
  try {
    final decoded = jsonDecode(row.farmIdsJson);
    if (decoded is! List) {
      return const [];
    }
    return decoded.map((entry) => entry.toString()).toList();
  } catch (_) {
    return const [];
  }
}

class ReminderPlanLoadResult {
  const ReminderPlanLoadResult({
    required this.tasks,
    required this.farmCount,
  });

  final List<ReminderPlanTask> tasks;
  final int farmCount;
}
