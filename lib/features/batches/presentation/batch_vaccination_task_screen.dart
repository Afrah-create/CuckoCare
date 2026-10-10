import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/layout/page_layout.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/not_found_state.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../core/time/kampala_today.dart';
import '../../../data_platform/db/app_database.dart';
import '../domain/task_state_calculator.dart';
import 'batch_detail_screen.dart';
import 'batch_display.dart';
import 'mark_task_done_sheet.dart';

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

    return AppPage(
      title: 'Vaccination task',
      preset: PageLayout.reading,
      frame: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _close(context),
      ),
      body: AsyncStateView<BatchRow?>(
        value: batchAsync,
        skeleton: const DetailSkeleton(),
        error: (_, __) => const _TaskMissingBody(),
        builder: (batch) {
          if (batch == null) {
            return const _TaskMissingBody();
          }
          return AsyncStateView<VaccinationTaskRow?>(
            value: taskAsync,
            skeleton: const DetailSkeleton(),
            error: (error, _) => ErrorState(
              failure: FailureMapper.mapObject(error),
              onRetry: () => ref.invalidate(
                vaccinationTaskProvider((batchId, taskId)),
              ),
            ),
            builder: (task) {
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

  Future<void> _markDone(BuildContext context) {
    return showMarkTaskDoneSheet(
      context,
      ref,
      task: task,
      today: today,
    );
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
    return NotFoundState(
      title: 'This task is no longer on this phone',
      message: 'Open Today to see what is due now.',
      actionLabel: 'Go to Today',
      onBack: () => const TodayRoute().go(context),
    );
  }
}
