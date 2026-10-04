import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/di/providers.dart';
import '../../notifications/presentation/notification_prefs_provider.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/cuco_confirm_dialog.dart';
import '../../../core/time/kampala_today.dart';
import '../../../data_platform/db/app_database.dart';
import '../domain/task_state_calculator.dart';
import 'batch_detail_screen.dart';
import 'batch_display.dart';

final vaccinationTaskProvider =
    StreamProvider.family<VaccinationTaskRow?, (String, String)>(
  (ref, key) {
    final taskId = key.$2;
    return ref.watch(batchRepositoryProvider).watchTask(taskId);
  },
);

class BatchVaccinationTaskScreen extends ConsumerWidget {
  const BatchVaccinationTaskScreen({
    required this.batchId,
    required this.taskId,
    super.key,
  });

  final String batchId;
  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchAsync = ref.watch(batchDetailProvider(batchId));
    final taskAsync = ref.watch(vaccinationTaskProvider((batchId, taskId)));
    final today = ref.watch(kampalaTodayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccination task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _close(context),
        ),
      ),
      body: batchAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const _TaskMissingBody(),
        data: (batch) {
          if (batch == null) {
            return const _TaskMissingBody();
          }
          return taskAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const _TaskMissingBody(),
            data: (task) {
              if (task == null || task.batchId != batchId) {
                return const _TaskMissingBody();
              }
              return _TaskBody(
                batch: batch,
                task: task,
                today: today,
                ref: ref,
              );
            },
          );
        },
      ),
    );
  }

  void _close(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    BatchDetailRoute(batchId: batchId).go(context);
  }
}

class _TaskBody extends StatelessWidget {
  const _TaskBody({
    required this.batch,
    required this.task,
    required this.today,
    required this.ref,
  });

  final BatchRow batch;
  final VaccinationTaskRow task;
  final DateTime today;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final label = _stepLabel(task.stepSnapshot, task.stepId);
    final due = DateFormat.yMMMEd().format(task.dueOn.toUtc());
    final ui = taskUiStateFor(task, today);
    final scheme = context.scheme;

    return ContentFrame(
      child: ListView(
        padding: EdgeInsets.only(
          bottom: ContentFrame.scrollBottomInset(context),
        ),
        children: [
          Text(
            label,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            batch.name,
            style: context.text.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 20,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Due $due',
                          style: context.text.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _DetailStatusChip(state: ui),
                ],
              ),
            ),
          ),
          if (task.notes != null && task.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: ListTile(
                leading: const Icon(Icons.notes_outlined),
                title: const Text('Notes'),
                subtitle: Text(task.notes!),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (taskUiStateAllowsMarkDone(ui))
            FilledButton.icon(
              onPressed: () => _markDone(context),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark as done'),
            ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => BatchDetailRoute(batchId: batch.id).push(context),
            icon: const Icon(Icons.list_alt_outlined),
            label: const Text('View full batch schedule'),
          ),
        ],
      ),
    );
  }

  String _stepLabel(String? snapshot, String fallback) {
    if (snapshot == null) {
      return fallback;
    }
    try {
      final map = jsonDecode(snapshot) as Map<String, dynamic>;
      return map['label'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _markDone(BuildContext context) async {
    final ok = await showCucoConfirmDialog(
      context: context,
      title: 'Mark as done?',
      message: 'Only confirm if you completed this step on your farm.',
      confirmLabel: 'Mark done',
      cancelLabel: 'Cancel',
    );
    if (ok != true) {
      return;
    }
    try {
      await ref.read(batchRepositoryProvider).markTaskDone(
            taskId: task.id,
            todayLocal: today,
            doneOn: DateTime.utc(today.year, today.month, today.day),
          );
      ref.read(reminderReconcilerProvider).scheduleReconcile();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task marked as done')),
        );
      }
    } on StateError catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }
}

class _DetailStatusChip extends StatelessWidget {
  const _DetailStatusChip({required this.state});

  final TaskUiState state;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final (bg, fg) = switch (state) {
      TaskUiState.done => (scheme.primaryContainer, scheme.onPrimaryContainer),
      TaskUiState.skipped =>
        (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
      TaskUiState.needsConfirmation =>
        (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      TaskUiState.dueToday =>
        (scheme.primaryContainer, scheme.onPrimaryContainer),
      TaskUiState.dueSoon =>
        (scheme.secondaryContainer, scheme.onSecondaryContainer),
      TaskUiState.overdueGentle ||
      TaskUiState.overdueUrgent =>
        (scheme.errorContainer, scheme.onErrorContainer),
      TaskUiState.upcoming =>
        (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
      TaskUiState.disabled =>
        (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        taskUiStateLabel(state),
        style: context.text.labelMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TaskMissingBody extends StatelessWidget {
  const _TaskMissingBody();

  @override
  Widget build(BuildContext context) {
    return ContentFrame(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 48,
              color: context.scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'This task is no longer on this phone',
              textAlign: TextAlign.center,
              style: context.text.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sign in and sync, or open Today to see what is due now.',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => const TodayRoute().go(context),
              child: const Text('Go to Today'),
            ),
          ],
        ),
      ),
    );
  }
}
