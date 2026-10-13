import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/layout/app_page.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/layout/page_layout.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/empty_state.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/not_found_state.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../app/di/providers.dart';
import '../domain/batch_metrics.dart';
import '../domain/calendar_date.dart';
import '../domain/loss_record.dart';
import 'batch_actions.dart';
import 'batch_labels.dart';
import 'batch_providers.dart';
import 'batch_widgets.dart';
import 'loss_detail_sheet.dart';

enum _Range { all, week, month }

/// Every loss for one batch, oldest-to-newest running count, shown newest first.
class LossesScreen extends ConsumerStatefulWidget {
  const LossesScreen({required this.batchId, super.key});

  final String batchId;

  @override
  ConsumerState<LossesScreen> createState() => _LossesScreenState();
}

class _LossesScreenState extends ConsumerState<LossesScreen> {
  LossKind? _kind;
  var _range = _Range.all;

  @override
  Widget build(BuildContext context) {
    final viewAsync = ref.watch(batchViewProvider(widget.batchId));
    final today = ref.watch(todayDateProvider);
    final highlighted = ref.watch(highlightedLossProvider);
    final permissions = ref.watch(batchPermissionsProvider);
    final view = viewAsync.value;
    final canRecord =
        view != null &&
        !view.isClosed &&
        view.metrics.liveCount > 0 &&
        permissions.canRecordLosses;

    return AppPage(
      title: 'Losses',
      preset: PageLayout.reading,
      frame: false,
      floatingActionButton: canRecord
          ? FloatingActionButton.extended(
              onPressed: () => openRecordLoss(context, ref, widget.batchId),
              icon: const Icon(Icons.add),
              label: const Text('Record loss'),
            )
          : null,
      body: AsyncStateView(
        value: viewAsync,
        skeleton: const ListSkeleton(),
        onRetry: () => ref.invalidate(batchViewProvider(widget.batchId)),
        error: (error, _) => ErrorState(
          failure: FailureMapper.mapObject(error),
          onRetry: () => ref.invalidate(batchViewProvider(widget.batchId)),
        ),
        builder: (data) {
          if (data == null) {
            return NotFoundState(onBack: () => context.pop());
          }
          if (data.losses.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_outline,
              title: 'No losses recorded',
              message: "That's good news.",
            );
          }
          final ledger = BatchMetrics.ledger(
            initialCount: data.metrics.initialCount,
            entries: data.losses,
          ).reversed.where(_matches(today)).toList();

          return ContentFrame(
            preset: PageLayout.reading,
            child: ListView(
              padding: EdgeInsets.only(
                top: AppSpacing.md,
                bottom:
                    ContentFrame.scrollBottomInset(context) + AppSpacing.xl * 2,
              ),
              children: [
                _Totals(metrics: data.metrics),
                const SizedBox(height: AppSpacing.md),
                _Filters(
                  kind: _kind,
                  range: _range,
                  onKind: (kind) => setState(() => _kind = kind),
                  onRange: (range) => setState(() => _range = range),
                ),
                const SizedBox(height: AppSpacing.md),
                if (ledger.isEmpty)
                  EmptyState(
                    kind: EmptyKind.filtered,
                    icon: Icons.filter_alt_off_outlined,
                    title: 'No matching losses',
                    message: 'Try a different filter.',
                    actionLabel: 'Clear filters',
                    onAction: () => setState(() {
                      _kind = null;
                      _range = _Range.all;
                    }),
                  )
                else
                  ..._grouped(context, ledger, data.isClosed, highlighted),
              ],
            ),
          );
        },
      ),
    );
  }

  bool Function(LedgerLine) _matches(CalendarDate today) {
    final from = switch (_range) {
      _Range.all => null,
      _Range.week => today.addDays(-6),
      _Range.month => today.addDays(-29),
    };
    return (line) {
      if (_kind != null && line.entry.kind != _kind) {
        return false;
      }
      return from == null || line.entry.occurredOn.compareTo(from) >= 0;
    };
  }

  List<Widget> _grouped(
    BuildContext context,
    List<LedgerLine> lines,
    bool closed,
    String? highlighted,
  ) {
    final widgets = <Widget>[];
    CalendarDate? week;
    CalendarDate? day;
    for (final line in lines) {
      final on = line.entry.occurredOn;
      final weekStart = on.addDays(
        -(DateTime(on.year, on.month, on.day).weekday - 1),
      );
      if (week != weekStart) {
        week = weekStart;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.xs,
            ),
            child: Text(
              'Week of ${formatDay(weekStart)}',
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
      if (day != on) {
        day = on;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              formatDay(on),
              style: context.text.labelMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }
      widgets.add(
        LossTile(
          entry: line.entry,
          liveAfter: line.liveAfter,
          highlight: line.entry.id == highlighted,
          onTap: () => showLossDetailSheet(
            context,
            ref,
            entry: line.entry,
            readOnly: closed,
          ),
        ),
      );
    }
    return widgets;
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.metrics});

  final BatchMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (metrics.diedCount > 0) '${formatCount(metrics.diedCount)} died',
      if (metrics.culledCount > 0) '${formatCount(metrics.culledCount)} culled',
      if (metrics.missingCount > 0)
        '${formatCount(metrics.missingCount)} missing',
      if (metrics.otherCount > 0) '${formatCount(metrics.otherCount)} other',
    ];
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${birdsLabel(metrics.totalLosses)} lost',
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              parts.join(' · '),
              style: context.text.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Mortality so far: ${formatPct(metrics.mortalityRatePct)}',
              style: context.text.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.kind,
    required this.range,
    required this.onKind,
    required this.onRange,
  });

  final LossKind? kind;
  final _Range range;
  final ValueChanged<LossKind?> onKind;
  final ValueChanged<_Range> onRange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ChoiceChip(
              label: const Text('All kinds'),
              selected: kind == null,
              onSelected: (_) => onKind(null),
            ),
            for (final k in LossKind.values)
              ChoiceChip(
                label: Text(lossKindLabel(k)),
                selected: kind == k,
                onSelected: (_) => onKind(k),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final (value, label) in const [
              (_Range.all, 'All time'),
              (_Range.week, 'Last 7 days'),
              (_Range.month, 'Last 30 days'),
            ])
              ChoiceChip(
                label: Text(label),
                selected: range == value,
                onSelected: (_) => onRange(value),
              ),
          ],
        ),
      ],
    );
  }
}
