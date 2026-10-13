import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/layout/layout_scope.dart';
import '../../../app/layout/page_layout.dart';
import '../../../app/layout/two_pane.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/inline_banner.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/not_found_state.dart';
import '../../../app/widgets/states/pending_sync_badge.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../core/time/kampala_today.dart';
import '../../../data_platform/db/app_database.dart';
import '../domain/batch_facts.dart';
import '../domain/batch_permissions.dart';
import '../domain/task_state_calculator.dart';
import '../../health/presentation/report_health_concern_sheet.dart';
import 'batch_actions.dart';
import 'batch_display.dart';
import 'batch_health_incidents_section.dart';
import 'batch_labels.dart';
import 'batch_providers.dart';
import 'batch_widgets.dart';
import 'loss_detail_sheet.dart';
import 'mark_task_done_sheet.dart';

final batchDetailProvider = StreamProvider.family<BatchRow?, String>((ref, id) {
  return ref.watch(batchRepositoryProvider).watchBatch(id);
});

final batchTasksProvider =
    StreamProvider.family<List<VaccinationTaskRow>, String>((ref, batchId) {
      return ref.watch(batchRepositoryProvider).watchTasksForBatch(batchId);
    });

enum _BatchMenu { edit, close, reopen, delete }

class BatchDetailScreen extends ConsumerWidget {
  const BatchDetailScreen({required this.batchId, super.key});

  final String batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewAsync = ref.watch(batchViewProvider(batchId));
    final tasksAsync = ref.watch(batchTasksProvider(batchId));
    final today = ref.watch(kampalaTodayProvider);
    final permissions = ref.watch(batchPermissionsProvider);
    final view = viewAsync.value;

    return AppPage(
      title: 'Batch',
      preset: PageLayout.reading,
      frame: false,
      actions: [
        if (view != null && permissions.canManageBatch)
          _BatchMenuButton(
            view: view,
            onSelected: (item) {
              _onMenu(context, ref, view, item);
            },
          ),
      ],
      floatingActionButton: view == null || view.isClosed
          ? null
          : FloatingActionButton.extended(
              heroTag: 'batch-incident',
              onPressed: () => showReportHealthConcernSheet(
                context,
                batchId: batchId,
                farmId: view.batch.farmId,
              ),
              icon: const Icon(Icons.medical_services_outlined),
              label: const Text('Incident'),
            ),
      body: AsyncStateView<BatchView?>(
        value: viewAsync,
        onRetry: () => ref.invalidate(batchViewProvider(batchId)),
        skeleton: const DetailSkeleton(),
        error: (error, _) => ErrorState(
          failure: FailureMapper.mapObject(error),
          onRetry: () => ref.invalidate(batchViewProvider(batchId)),
        ),
        builder: (data) {
          if (data == null) {
            return NotFoundState(onBack: () => context.pop());
          }
          return AsyncStateView<List<VaccinationTaskRow>>(
            value: tasksAsync,
            expand: true,
            skeleton: const DetailSkeleton(),
            error: (error, _) => ErrorState(
              failure: FailureMapper.mapObject(error),
              onRetry: () => ref.invalidate(batchTasksProvider(batchId)),
            ),
            onRetry: () => ref.invalidate(batchTasksProvider(batchId)),
            builder: (tasks) => _BatchDetailBody(
              view: data,
              tasks: tasks,
              today: today,
              permissions: permissions,
              ref: ref,
            ),
          );
        },
      ),
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    BatchView view,
    _BatchMenu item,
  ) async {
    switch (item) {
      case _BatchMenu.edit:
        await openEditBatch(context, view.batch.id);
      case _BatchMenu.close:
        await closeBatch(context, ref, view.batch);
      case _BatchMenu.reopen:
        await reopenBatch(context, ref, view.batch);
      case _BatchMenu.delete:
        final deleted = await confirmDeleteBatch(context, ref, view.batch);
        if (deleted && context.mounted) {
          context.pop();
        }
    }
  }
}

class _BatchMenuButton extends StatelessWidget {
  const _BatchMenuButton({required this.view, required this.onSelected});

  final BatchView view;
  final ValueChanged<_BatchMenu> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_BatchMenu>(
      tooltip: 'Batch actions',
      onSelected: onSelected,
      itemBuilder: (context) => [
        if (!view.isClosed)
          const PopupMenuItem(
            value: _BatchMenu.edit,
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit batch'),
            ),
          ),
        if (view.isClosed)
          const PopupMenuItem(
            value: _BatchMenu.reopen,
            child: ListTile(
              leading: Icon(Icons.lock_open_outlined),
              title: Text('Reopen batch'),
            ),
          )
        else
          const PopupMenuItem(
            value: _BatchMenu.close,
            child: ListTile(
              leading: Icon(Icons.inventory_2_outlined),
              title: Text('Close batch'),
            ),
          ),
        const PopupMenuItem(
          value: _BatchMenu.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Delete batch'),
          ),
        ),
      ],
    );
  }
}

class _BatchDetailBody extends StatelessWidget {
  const _BatchDetailBody({
    required this.view,
    required this.tasks,
    required this.today,
    required this.permissions,
    required this.ref,
  });

  final BatchView view;
  final List<VaccinationTaskRow> tasks;
  final DateTime today;
  final BatchPermissions permissions;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final summary = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeaderCard(view: view),
        ..._notices(context),
        const SizedBox(height: AppSpacing.md),
        BatchStatsCard(metrics: view.metrics),
        const SizedBox(height: AppSpacing.md),
        _RecordLossAction(view: view, permissions: permissions, ref: ref),
      ],
    );
    final activity = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RecentLosses(view: view, ref: ref),
        const SizedBox(height: AppSpacing.lg),
        ..._taskSections(context),
        BatchHealthIncidentsSection(batchId: view.batch.id),
      ],
    );

    return ContentFrame(
      preset: context.layout.useTwoPane
          ? PageLayout.standard
          : PageLayout.reading,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: AppSpacing.md,
          bottom: ContentFrame.scrollBottomInset(context) + AppSpacing.xl * 2,
        ),
        child: TwoPane(primary: summary, secondary: activity),
      ),
    );
  }

  List<Widget> _notices(BuildContext context) {
    final metrics = view.metrics;
    final notices = <Widget>[];
    if (metrics.isInconsistent) {
      notices.add(
        _Notice(
          banner: const InlineBanner(
            message: 'Loss records exceed the birds placed. Please review.',
            icon: Icons.rule_outlined,
            tone: BannerTone.warning,
          ),
          actionLabel: 'Review losses',
          onAction: () =>
              BatchLossesRoute(batchId: view.batch.id).push(context),
        ),
      );
    } else if (metrics.allLost && !view.isClosed) {
      notices.add(
        _Notice(
          banner: const InlineBanner(
            message: 'All birds are recorded as lost. Close this batch?',
            icon: Icons.info_outline,
            tone: BannerTone.info,
          ),
          actionLabel: permissions.canManageBatch ? 'Close batch' : null,
          onAction: () => closeBatch(context, ref, view.batch),
        ),
      );
    }
    return notices;
  }

  List<Widget> _taskSections(BuildContext context) {
    final enabled = tasks.where((t) => t.enabled).toList();
    final confirm = <VaccinationTaskRow>[];
    final active = <VaccinationTaskRow>[];
    final completed = <VaccinationTaskRow>[];
    final readOnly = view.isClosed;

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

    VoidCallback? markDone(VaccinationTaskRow t) =>
        readOnly ? null : () => _markDone(context, t);

    return [
      if (confirm.isNotEmpty) ...[
        _SectionHeading(title: 'Confirm these steps', count: confirm.length),
        const SizedBox(height: AppSpacing.sm),
        ...confirm.map(
          (t) => _TaskTile(task: t, today: today, onMarkDone: markDone(t)),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
      _SectionHeading(title: 'To do', count: active.length),
      const SizedBox(height: AppSpacing.sm),
      if (active.isEmpty)
        Text(
          readOnly
              ? 'This batch is closed. Its reminders are paused.'
              : 'Nothing scheduled right now.',
          style: context.text.bodyMedium?.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        )
      else
        ...active.map(
          (t) => _TaskTile(task: t, today: today, onMarkDone: markDone(t)),
        ),
      if (completed.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.lg),
        _SectionHeading(title: 'Completed', count: completed.length),
        const SizedBox(height: AppSpacing.sm),
        ...completed.map(
          (t) => _TaskTile(task: t, today: today, onMarkDone: null),
        ),
      ],
    ];
  }

  Future<void> _markDone(BuildContext context, VaccinationTaskRow task) {
    return showMarkTaskDoneSheet(
      context,
      ref,
      task: task,
      today: ref.read(kampalaTodayProvider),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.view});

  final BatchView view;

  @override
  Widget build(BuildContext context) {
    final batch = view.batch;
    final facts = view.facts;
    final metrics = view.metrics;
    final muted = context.text.bodyMedium?.copyWith(
      color: context.scheme.onSurfaceVariant,
    );
    final reason = CloseReason.fromStorage(batch.closeReason);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    batch.name,
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (view.isClosed) ...[
                  const ClosedTag(),
                  const SizedBox(width: AppSpacing.xs),
                ],
                PendingSyncBadge(rowId: batch.id),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${birdTypeLabel(batch.birdType)} · Day ${metrics.ageDays} '
              '(Week ${metrics.ageWeeks})',
              style: muted,
            ),
            Text(
              'Hatched ${formatDay(facts.hatchedOn)} · '
              'Arrived ${formatDay(facts.acquiredOn)}',
              style: muted,
            ),
            if (view.isClosed && facts.closedOn != null)
              Text(
                'Closed ${formatDay(facts.closedOn!)}'
                '${reason == null ? '' : ' · ${closeReasonLabel(reason)}'}',
                style: muted,
              ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.banner, this.actionLabel, this.onAction});

  final Widget banner;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          banner,
          if (actionLabel != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ),
        ],
      ),
    );
  }
}

class _RecordLossAction extends StatelessWidget {
  const _RecordLossAction({
    required this.view,
    required this.permissions,
    required this.ref,
  });

  final BatchView view;
  final BatchPermissions permissions;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final reason =
        permissions.recordLossBlockedReason ??
        (view.isClosed
            ? 'This batch is closed. Reopen it to record losses.'
            : view.metrics.liveCount == 0
            ? 'There are no live birds left in this batch.'
            : null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
          onPressed: reason == null
              ? () => openRecordLoss(context, ref, view.batch.id)
              : null,
          icon: const Icon(Icons.remove_circle_outline),
          label: const Text('Record loss'),
        ),
        if (reason != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            reason,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
        ],
        if (view.isClosed && permissions.canManageBatch) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => reopenBatch(context, ref, view.batch),
            icon: const Icon(Icons.lock_open_outlined),
            label: const Text('Reopen batch'),
          ),
        ],
      ],
    );
  }
}

class _RecentLosses extends StatelessWidget {
  const _RecentLosses({required this.view, required this.ref});

  final BatchView view;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final highlighted = ref.watch(highlightedLossProvider);
    final recent = view.losses.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _SectionHeading(
                title: 'Recent losses',
                count: view.losses.length,
              ),
            ),
            if (view.losses.isNotEmpty)
              TextButton(
                onPressed: () =>
                    BatchLossesRoute(batchId: view.batch.id).push(context),
                child: const Text('See all'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (recent.isEmpty)
          Text(
            'No losses recorded.',
            style: context.text.bodyMedium?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          )
        else
          for (final entry in recent)
            LossTile(
              entry: entry,
              highlight: entry.id == highlighted,
              onTap: () => showLossDetailSheet(
                context,
                ref,
                entry: entry,
                readOnly: view.isClosed,
              ),
            ),
      ],
    );
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
      TaskUiState.overdueUrgent => (Icons.warning_amber_outlined, scheme.error),
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
      TaskUiState.skipped => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
      TaskUiState.needsConfirmation => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      TaskUiState.dueToday => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      TaskUiState.dueSoon => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      TaskUiState.overdueGentle || TaskUiState.overdueUrgent => (
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      TaskUiState.upcoming => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
      TaskUiState.disabled => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
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
