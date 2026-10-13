import 'package:flutter/material.dart';

import '../../../app/layout/layout_scope.dart';
import '../../../app/theme/app_motion.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/animated_count.dart';
import '../../../app/widgets/states/highlight_on_insert.dart';
import '../../../app/widgets/states/pending_sync_badge.dart';
import '../domain/batch_metrics.dart';
import '../domain/loss_record.dart';
import 'batch_labels.dart';

/// The flock at a glance: live birds, the main rates, and the 14-day trend.
class BatchStatsCard extends StatelessWidget {
  const BatchStatsCard({required this.metrics, super.key});

  final BatchMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final muted = context.text.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final placed = metrics.initialCount;
    final share = placed == 0 ? 0.0 : metrics.liveCount / placed;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              container: true,
              excludeSemantics: true,
              label:
                  'Live birds, ${formatCount(metrics.liveCount)} '
                  'of ${formatCount(placed)} placed',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live birds',
                          style: context.text.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: AnimatedCount(
                            value: metrics.liveCount,
                            format: formatCount,
                            style: context.text.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!context.layout.isLargeText) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        'of ${formatCount(placed)} placed',
                        textAlign: TextAlign.end,
                        style: muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (context.layout.isLargeText)
              ExcludeSemantics(
                child: Text('of ${formatCount(placed)} placed', style: muted),
              ),
            const SizedBox(height: AppSpacing.sm),
            _ShareBar(fraction: share),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            _StatRow(
              stats: [
                _Stat(
                  label: 'Losses',
                  count: metrics.totalLosses,
                  caption: '${formatPct(metrics.totalLossRatePct)} of placed',
                ),
                _Stat(
                  label: 'Mortality',
                  value: formatPct(metrics.mortalityRatePct),
                  caption: '${formatCount(metrics.diedCount)} died',
                ),
                _Stat(
                  label: 'Today',
                  count: metrics.lossesToday,
                  caption: '${formatCount(metrics.losses7d)} in 7 days',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Last ${BatchMetrics.sparklineDays} days',
                    style: context.text.titleSmall,
                  ),
                ),
                Text(birdsLabel(metrics.sparklineTotal), style: muted),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LossSparkline(metrics: metrics, height: 44),
          ],
        ),
      ),
    );
  }
}

class _ShareBar extends StatelessWidget {
  const _ShareBar({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final motion = AppMotion.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: SizedBox(
        height: AppSpacing.xs,
        child: ColoredBox(
          color: scheme.surfaceContainerHighest,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: fraction.clamp(0.0, 1.0)),
            duration: motion.standard,
            curve: motion.curveStandard,
            builder: (context, value, _) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: ColoredBox(color: scheme.primary),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat {
  const _Stat({
    required this.label,
    required this.caption,
    this.count,
    this.value,
  });

  final String label;
  final String caption;
  final int? count;
  final String? value;
}

/// Equal columns split by thin rules; stacks as rows at large text sizes.
class _StatRow extends StatelessWidget {
  const _StatRow({required this.stats});

  final List<_Stat> stats;

  @override
  Widget build(BuildContext context) {
    if (context.layout.isLargeText) {
      return Column(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            _StatCell(stat: stats[i], inline: true),
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const VerticalDivider(width: AppSpacing.lg),
            Expanded(child: _StatCell(stat: stats[i])),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.stat, this.inline = false});

  final _Stat stat;
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final shown = stat.count != null
        ? formatCount(stat.count!)
        : stat.value ?? '';
    final valueStyle = context.text.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final value = stat.count != null
        ? AnimatedCount(
            value: stat.count!,
            format: formatCount,
            style: valueStyle,
          )
        : Text(shown, style: valueStyle);
    final label = Text(
      stat.label,
      style: context.text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
    );
    final caption = Text(
      stat.caption,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: context.text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
    );

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '${stat.label}, $shown, ${stat.caption}',
      child: inline
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [label, caption],
                  ),
                ),
                value,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label,
                const SizedBox(height: AppSpacing.xxs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: value,
                ),
                const SizedBox(height: 2),
                caption,
              ],
            ),
    );
  }
}

/// Bars for losses per day, oldest on the left.
class LossSparkline extends StatelessWidget {
  const LossSparkline({required this.metrics, this.height = 56, super.key});

  final BatchMetrics metrics;
  final double height;

  @override
  Widget build(BuildContext context) {
    final total = metrics.sparklineTotal;
    final description =
        'Losses in the last ${BatchMetrics.sparklineDays} days: '
        '${birdsLabel(total)} in total';
    return Semantics(
      label: description,
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _SparklinePainter(
            values: metrics.dailyLosses,
            bar: context.scheme.error,
            baseline: context.scheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.bar,
    required this.baseline,
  });

  final List<int> values;
  final Color bar;
  final Color baseline;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }
    final maxValue = values.fold<int>(0, (m, v) => v > m ? v : m);
    final slot = size.width / values.length;
    final barWidth = slot * 0.6;
    final barPaint = Paint()..color = bar;
    final basePaint = Paint()
      ..color = baseline
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - 0.5),
      Offset(size.width, size.height - 0.5),
      basePaint,
    );
    if (maxValue == 0) {
      return;
    }
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v == 0) {
        continue;
      }
      final h = (v / maxValue) * (size.height - 4);
      final left = i * slot + (slot - barWidth) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, size.height - h - 1, barWidth, h),
          const Radius.circular(2),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.values != values || old.bar != bar || old.baseline != baseline;
}

/// One loss record row: kind, count, date, and live birds after it.
class LossTile extends StatelessWidget {
  const LossTile({
    required this.entry,
    this.liveAfter,
    this.batchName,
    this.highlight = false,
    this.onTap,
    super.key,
  });

  final LossEntry entry;
  final int? liveAfter;
  final String? batchName;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final details = <String>[
      ?batchName,
      formatDay(entry.occurredOn),
      if (entry.suspectedCause != null) causeLabel(entry.suspectedCause!),
    ];
    return HighlightOnInsert(
      active: highlight,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: scheme.surfaceContainerHighest,
                  child: Icon(
                    lossKindIcon(entry.kind),
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xxs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${lossKindLabel(entry.kind)} · ${birdsLabel(entry.count)}',
                            style: context.text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (entry.isEdited) const _EditedTag(),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        details.join(' · '),
                        style: context.text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (entry.notes != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          entry.notes!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PendingSyncBadge(rowId: entry.id),
                    if (liveAfter != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${formatCount(liveAfter!)} left',
                        style: context.text.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditedTag extends StatelessWidget {
  const _EditedTag();

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Edited',
        style: context.text.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Small tag shown on closed batches.
class ClosedTag extends StatelessWidget {
  const ClosedTag({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Closed',
        style: context.text.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
