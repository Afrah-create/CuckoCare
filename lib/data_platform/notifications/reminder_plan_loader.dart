import 'package:drift/drift.dart';

import '../../features/batches/domain/calendar_date.dart';
import '../../features/notifications/domain/reminder_planner.dart';
import '../../features/notifications/domain/step_snapshot.dart';
import '../db/app_database.dart';

class ReminderPlanLoader {
  const ReminderPlanLoader();

  Future<ReminderPlanLoadResult> load(AppDatabase db) async {
    final farms = await (db.select(db.farms)
          ..where((f) => f.deletedAt.isNull()))
        .get();
    final farmNames = {for (final f in farms) f.id: f.name};

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
      tasks.add(
        ReminderPlanTask(
          taskId: row.id,
          batchId: row.batchId,
          farmId: row.farmId,
          batchName: batch.name,
          farmName: farmNames[row.farmId] ?? 'Farm',
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
      farmCount: farms.length,
    );
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
