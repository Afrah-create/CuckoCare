import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/di/providers.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../notifications/presentation/notification_prefs_provider.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/time/kampala_today.dart';
import '../../../data_platform/db/app_database.dart';
import '../domain/task_state_calculator.dart';
import '../../health/presentation/report_health_concern_sheet.dart';
import 'batch_display.dart';
import 'batch_health_incidents_section.dart';

final batchDetailProvider = StreamProvider.family<BatchRow?, String>((ref, id) {
  return ref.watch(batchRepositoryProvider).watchBatch(id);
});

final batchTasksProvider =
    StreamProvider.family<List<VaccinationTaskRow>, String>((ref, batchId) {
  return ref.watch(batchRepositoryProvider).watchTasksForBatch(batchId);
});

class BatchDetailScreen extends ConsumerWidget {
  const BatchDetailScreen({required this.batchId, super.key});

  final String batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchAsync = ref.watch(batchDetailProvider(batchId));
    final tasksAsync = ref.watch(batchTasksProvider(batchId));
    final today = ref.watch(kampalaTodayProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Batch')),
      floatingActionButton: batchAsync.maybeWhen(
        data: (batch) => batch == null
            ? null
            : FloatingActionButton.extended(
                onPressed: () => showReportHealthConcernSheet(
                  context,
                  batchId: batchId,
                  farmId: batch.farmId,
                ),
                icon: const Icon(Icons.medical_services_outlined),
                label: const Text('Incident'),
              ),
        orElse: () => null,
      ),
      body: batchAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Batch not found')),
        data: (batch) {
          if (batch == null) {
            return const Center(child: Text('Batch not found'));
          }
          return tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Could not load schedule')),
            data: (tasks) => _BatchDetailBody(
              batch: batch,
              batchId: batchId,
              tasks: tasks,
              today: today,
              ref: ref,
            ),
          );
        },
      ),
    );
  }
}

class _BatchDetailBody extends StatelessWidget {
  const _BatchDetailBody({
    required this.batch,
    required this.batchId,
    required this.tasks,
    required this.today,
    required this.ref,
  });

  final BatchRow batch;
  final String batchId;
  final List<VaccinationTaskRow> tasks;
  final DateTime today;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final enabled = tasks.where((t) => t.enabled).toList();
    final confirm = <VaccinationTaskRow>[];
    final active = <VaccinationTaskRow>[];
    final completed = <VaccinationTaskRow>[];

    for (final task in enabled) {
      final ui = taskUiStateFor(task, today);
      if (ui == TaskUiState.needsConfirmation) {
        confirm.add(task);
      } else if (ui == TaskUiState.done || ui == TaskUiState.skipped) {
        completed.add(task);
      } else if (ui != TaskUiState.disabled) {
        active.add(task);
      }
    }

    int sortKey(VaccinationTaskRow t) {
      final ui = taskUiStateFor(t, today);
      return switch (ui) {
        TaskUiState.overdueUrgent => 0,
        TaskUiState.overdueGentle => 1,
        TaskUiState.dueToday => 2,
        TaskUiState.dueSoon => 3,
        TaskUiState.upcoming => 4,
        _ => 5,
      };
    }

    active.sort((a, b) {
      final byUrgency = sortKey(a).compareTo(sortKey(b));
      if (byUrgency != 0) {
        return byUrgency;
      }
      return a.dueOn.compareTo(b.dueOn);
    });

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        ContentFrame.scrollBottomInset(context),
      ),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.name,
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${birdTypeLabel(batch.birdType)} · ${batchAgeLabel(batch, today)} · ${batch.initialCount} birds',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (confirm.isNotEmpty) ...[
          _SectionHeading(title: 'Confirm these steps', count: confirm.length),
          const SizedBox(height: AppSpacing.sm),
          ...confirm.map(
            (t) => _TaskTile(
              task: t,
              today: today,
              onMarkDone: () => _markDone(context, t),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        _SectionHeading(
          title: 'To do',
          count: active.length,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (active.isEmpty)
          Text(
            'Nothing scheduled right now.',
            style: context.text.bodyMedium?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          )
        else
          ...active.map(
            (t) => _TaskTile(
              task: t,
              today: today,
              onMarkDone: () => _markDone(context, t),
            ),
          ),
        if (completed.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _SectionHeading(title: 'Completed', count: completed.length),
          const SizedBox(height: AppSpacing.sm),
          ...completed.map(
            (t) => _TaskTile(
              task: t,
              today: today,
              onMarkDone: null,
            ),
          ),
        ],
        BatchHealthIncidentsSection(batchId: batchId),
      ],
    );
  }

  Future<void> _markDone(BuildContext context, VaccinationTaskRow task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as done?'),
        content: const Text(
          'Only mark done if you completed this step on your farm.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Mark done'),
          ),
        ],
      ),
    );
    if (ok != true) {
      return;
    }
    final todayLocal = ref.read(kampalaTodayProvider);
    try {
      await ref.read(batchRepositoryProvider).markTaskDone(
            taskId: task.id,
            todayLocal: todayLocal,
            doneOn: DateTime.utc(
              todayLocal.year,
              todayLocal.month,
              todayLocal.day,
            ),
          );
      ref.read(reminderReconcilerProvider).scheduleReconcile();
    } on StateError catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$count',
          style: context.text.labelLarge?.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.today,
    required this.onMarkDone,
  });

  final VaccinationTaskRow task;
  final DateTime today;
  final VoidCallback? onMarkDone;

  @override
  Widget build(BuildContext context) {
    final label = _label(task.stepSnapshot);
    final due = DateFormat.yMMMd().format(task.dueOn.toUtc());
    final ui = taskUiStateFor(task, today);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => BatchVaccinationTaskRoute(
          batchId: task.batchId,
          taskId: task.id,
        ).push(context),
        child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.xs,
          AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusIcon(state: ui),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    due,
                    style: context.text.bodySmall?.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _StatusChip(state: ui),
                ],
              ),
            ),
            if (onMarkDone != null && taskUiStateAllowsMarkDone(ui))
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: 'Mark done',
                onPressed: onMarkDone,
              )
            else
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
      ),
    );
  }

  String _label(String? snapshot) {
    if (snapshot == null) {
      return task.stepId;
    }
    try {
      final map = jsonDecode(snapshot) as Map<String, dynamic>;
      return map['label'] as String? ?? task.stepId;
    } catch (_) {
      return task.stepId;
    }
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.state});

  final TaskUiState state;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final (icon, color) = switch (state) {
      TaskUiState.done => (Icons.check_circle, scheme.primary),
      TaskUiState.skipped => (Icons.remove_circle_outline, scheme.outline),
      TaskUiState.needsConfirmation => (Icons.help_outline, scheme.tertiary),
      TaskUiState.dueToday => (Icons.today_outlined, scheme.primary),
      TaskUiState.dueSoon => (Icons.schedule, scheme.secondary),
      TaskUiState.overdueGentle ||
      TaskUiState.overdueUrgent =>
        (Icons.warning_amber_outlined, scheme.error),
      TaskUiState.upcoming => (Icons.event_outlined, scheme.outline),
      TaskUiState.disabled => (Icons.visibility_off_outlined, scheme.outline),
    };
    return Icon(icon, color: color, size: 28);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.state});

  final TaskUiState state;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final (bg, fg) = switch (state) {
      TaskUiState.done => (scheme.primaryContainer, scheme.onPrimaryContainer),
      TaskUiState.skipped => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
      TaskUiState.needsConfirmation =>
        (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      TaskUiState.dueToday => (scheme.primaryContainer, scheme.onPrimaryContainer),
      TaskUiState.dueSoon => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      TaskUiState.overdueGentle ||
      TaskUiState.overdueUrgent =>
        (scheme.errorContainer, scheme.onErrorContainer),
      TaskUiState.upcoming => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
      TaskUiState.disabled => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        taskUiStateLabel(state),
        style: context.text.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
