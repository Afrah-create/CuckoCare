import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/layout/layout_scope.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/motion/appear.dart';
import '../../../app/widgets/motion/press_scale.dart';
import '../../../app/widgets/states/animated_count.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/empty_state.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/pending_sync_badge.dart';
import '../../../app/widgets/states/pull_to_refresh.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../app/widgets/status_chip.dart';
import '../../../core/error/failure_mapper.dart';
import '../data/batch_views.dart';
import '../domain/batch_permissions.dart';
import '../domain/task_state_calculator.dart';
import 'batch_actions.dart';
import 'batch_display.dart';
import 'batch_labels.dart';
import 'batch_providers.dart';
import 'batch_widgets.dart';

class BatchesListScreen extends ConsumerStatefulWidget {
  const BatchesListScreen({super.key});

  @override
  ConsumerState<BatchesListScreen> createState() => _BatchesListScreenState();
}

class _BatchesListScreenState extends ConsumerState<BatchesListScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: ref.read(batchListQueryProvider).search,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(syncEngineProvider).syncOnce(force: true);
  }

  void _clearSearch() {
    _search.clear();
    ref.read(batchListQueryProvider.notifier).setSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final totalsAsync = ref.watch(farmBatchTotalsProvider);
    final summariesAsync = ref.watch(batchSummariesProvider);
    final query = ref.watch(batchListQueryProvider);
    final permissions = ref.watch(batchPermissionsProvider);
    final online = ref.watch(connectivityOnlineProvider).value ?? true;
    final totals = totalsAsync.value;
    final hasAnyBatch =
        totals == null || totals.activeBatches + totals.closedBatches > 0;

    return AppPage(
      primary: false,
      frame: false,
      floatingActionButton: hasAnyBatch && permissions.canRecordLosses
          ? FloatingActionButton.extended(
              heroTag: 'batches-add',
              onPressed: () => const BatchNewRoute().push(context),
              icon: const Icon(Icons.add),
              label: const Text('Add batch'),
            )
          : null,
      body: AsyncStateView(
        value: totalsAsync,
        skeleton: const ListSkeleton(),
        onRetry: () => ref.invalidate(allBatchSummariesProvider),
        isEmpty: (t) => t.activeBatches + t.closedBatches == 0,
        empty: EmptyState(
          title: 'No batches yet',
          message: 'Add your first batch to start tracking.',
          actionLabel: 'Add batch',
          onAction: () => const BatchNewRoute().push(context),
          showMark: true,
        ),
        error: (error, _) => ErrorState(
          failure: FailureMapper.mapObject(error),
          onRetry: () => ref.invalidate(allBatchSummariesProvider),
        ),
        builder: (t) => PullToRefresh(
          online: online,
          onSync: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ContentFrame(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: _Controls(
                      totals: t,
                      query: query,
                      search: _search,
                      onClearSearch: _clearSearch,
                    ),
                  ),
                ),
              ),
              ..._results(context, summariesAsync, query, permissions),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _results(
    BuildContext context,
    AsyncValue<List<BatchSummary>> summariesAsync,
    BatchListQuery query,
    BatchPermissions permissions,
  ) {
    final bottom = ContentFrame.scrollBottomInset(context) + AppSpacing.xl * 2;
    Widget boxed(Widget child) => SliverToBoxAdapter(
      child: ContentFrame(
        child: Padding(
          padding: EdgeInsets.only(top: AppSpacing.md, bottom: bottom),
          child: child,
        ),
      ),
    );

    final items = summariesAsync.value;
    if (summariesAsync.hasError && items == null) {
      return [
        boxed(
          ErrorState(
            failure: FailureMapper.mapObject(summariesAsync.error!),
            onRetry: () => ref.invalidate(batchSummariesProvider),
          ),
        ),
      ];
    }
    if (items == null) {
      return [boxed(const ListSkeleton(count: 3, scrollable: false))];
    }
    if (items.isEmpty) {
      final searching = query.search.trim().isNotEmpty;
      return [
        boxed(
          EmptyState(
            kind: EmptyKind.filtered,
            icon: searching ? Icons.search_off : Icons.inventory_2_outlined,
            title: searching
                ? 'No matches'
                : query.filter == BatchListFilter.closed
                ? 'No closed batches yet'
                : 'No active batches',
            message: searching
                ? 'No batch name matches "${query.search.trim()}".'
                : query.filter == BatchListFilter.closed
                ? 'Close a batch when it is finished to keep its history here.'
                : 'Add a batch or look under Closed.',
            actionLabel: searching ? 'Clear search' : null,
            onAction: searching ? _clearSearch : null,
          ),
        ),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: ContentFrame(
          child: Padding(
            padding: EdgeInsets.only(top: AppSpacing.md, bottom: bottom),
            child: _CardGrid(
              children: [
                for (final entry in items.asMap().entries)
                  Appear(
                    delay: appearStagger(entry.key),
                    child: PressScale(
                      child: _BatchCard(
                        summary: entry.value,
                        permissions: permissions,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ];
  }
}

class _Controls extends ConsumerWidget {
  const _Controls({
    required this.totals,
    required this.query,
    required this.search,
    required this.onClearSearch,
  });

  final FarmBatchTotals totals;
  final BatchListQuery query;
  final TextEditingController search;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(batchListQueryProvider.notifier);
    final headline = context.text.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label:
              '${totals.activeBatches} active batches, '
              '${formatCount(totals.liveBirds)} live birds',
          excludeSemantics: true,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AnimatedCount(value: totals.activeBatches, style: headline),
              Text(
                totals.activeBatches == 1
                    ? ' active batch · '
                    : ' active batches · ',
                style: headline,
              ),
              AnimatedCount(
                value: totals.liveBirds,
                format: formatCount,
                style: headline,
              ),
              Text(' live birds', style: headline),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SegmentedButton<BatchListFilter>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: BatchListFilter.active, label: Text('Active')),
            ButtonSegment(value: BatchListFilter.closed, label: Text('Closed')),
            ButtonSegment(value: BatchListFilter.all, label: Text('All')),
          ],
          selected: {query.filter},
          onSelectionChanged: (s) => notifier.setFilter(s.first),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search batches',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.search.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close),
                          onPressed: onClearSearch,
                        ),
                ),
                onChanged: notifier.setSearch,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            PopupMenuButton<BatchSort>(
              tooltip: 'Sort',
              icon: const Icon(Icons.sort),
              initialValue: query.sort,
              onSelected: notifier.setSort,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: BatchSort.newest,
                  child: Text('Newest first'),
                ),
                PopupMenuItem(value: BatchSort.name, child: Text('Name')),
                PopupMenuItem(
                  value: BatchSort.age,
                  child: Text('Oldest birds first'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// One column on phones, two on landscape and tablets. Rows size to content.
class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = !layout.isLargeText && constraints.maxWidth >= 600
            ? 2
            : 1;
        if (columns == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        }
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: children[i]),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: i + 1 < children.length
                        ? children[i + 1]
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}

enum _CardAction { recordLoss, edit, close, reopen, delete }

class _BatchCard extends ConsumerWidget {
  const _BatchCard({required this.summary, required this.permissions});

  final BatchSummary summary;
  final BatchPermissions permissions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batch = summary.batch;
    final metrics = summary.metrics;
    final scheme = context.scheme;
    final actions = <_CardAction>[
      if (!summary.isClosed &&
          metrics.liveCount > 0 &&
          permissions.canRecordLosses)
        _CardAction.recordLoss,
      if (!summary.isClosed && permissions.canManageBatch) _CardAction.edit,
      if (permissions.canManageBatch)
        summary.isClosed ? _CardAction.reopen : _CardAction.close,
      if (permissions.canManageBatch) _CardAction.delete,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => BatchDetailRoute(batchId: batch.id).push(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      batch.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (summary.isClosed) const ClosedTag(),
                  PendingSyncBadge(rowId: batch.id),
                  if (actions.isNotEmpty)
                    PopupMenuButton<_CardAction>(
                      tooltip: 'Batch actions',
                      onSelected: (action) => _run(context, ref, action),
                      itemBuilder: (context) => [
                        for (final action in actions)
                          PopupMenuItem(
                            value: action,
                            child: Text(_label(action)),
                          ),
                      ],
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
              Text(
                '${birdTypeLabel(batch.birdType)} · Week ${metrics.ageWeeks}',
                style: context.text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: AppSpacing.xs,
                children: [
                  AnimatedCount(
                    value: metrics.liveCount,
                    format: formatCount,
                    style: context.text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      'of ${formatCount(metrics.initialCount)} placed',
                      style: context.text.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Mortality so far: ${formatPct(metrics.mortalityRatePct)}',
                    style: context.text.bodySmall,
                  ),
                  if (summary.nextDueState != null)
                    _NextTaskChip(state: summary.nextDueState!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _label(_CardAction action) => switch (action) {
    _CardAction.recordLoss => 'Record loss',
    _CardAction.edit => 'Edit',
    _CardAction.close => 'Close batch',
    _CardAction.reopen => 'Reopen batch',
    _CardAction.delete => 'Delete',
  };

  Future<void> _run(BuildContext context, WidgetRef ref, _CardAction action) {
    final batch = summary.batch;
    return switch (action) {
      _CardAction.recordLoss => openRecordLoss(context, ref, batch.id),
      _CardAction.edit => openEditBatch(context, batch.id),
      _CardAction.close => closeBatch(context, ref, batch),
      _CardAction.reopen => reopenBatch(context, ref, batch),
      _CardAction.delete => confirmDeleteBatch(context, ref, batch),
    };
  }
}

class _NextTaskChip extends StatelessWidget {
  const _NextTaskChip({required this.state});

  final TaskUiState state;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final (icon, bg, fg) = switch (state) {
      TaskUiState.overdueGentle || TaskUiState.overdueUrgent => (
        Icons.warning_amber_outlined,
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      TaskUiState.dueToday => (
        Icons.today_outlined,
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      TaskUiState.dueSoon => (
        Icons.schedule,
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      _ => (
        Icons.event_outlined,
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
    };
    return StatusChip(
      label: 'Next task: ${taskUiStateLabel(state)}',
      icon: icon,
      background: bg,
      foreground: fg,
    );
  }
}
