import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/layout/layout_scope.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/motion/appear.dart';
import '../../../app/widgets/states/animated_count.dart';
import '../domain/vet_inbox_stats.dart';

class VetRequestsStatsPanel extends StatelessWidget {
  const VetRequestsStatsPanel({required this.stats, super.key});

  final VetInboxStats stats;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final cols = layout.statColumns.clamp(2, 4);
    final maxH = layout.statCardMaxHeight;
    final scheme = context.scheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = AppSpacing.sm * (cols - 1);
            final tileWidth = (constraints.maxWidth - gap) / cols;
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                Appear(
                  child: _GlanceTile(
                    width: tileWidth,
                    maxHeight: maxH,
                    icon: Icons.inbox_outlined,
                    label: 'New requests',
                    count: stats.pending,
                  ),
                ),
                Appear(
                  delay: appearStagger(1),
                  child: _GlanceTile(
                    width: tileWidth,
                    maxHeight: maxH,
                    icon: Icons.assignment_outlined,
                    label: 'Active cases',
                    count: stats.active,
                  ),
                ),
                Appear(
                  delay: appearStagger(2),
                  child: _GlanceTile(
                    width: tileWidth,
                    maxHeight: maxH,
                    icon: Icons.directions_walk_outlined,
                    label: 'In progress',
                    count: stats.inProgress,
                  ),
                ),
                Appear(
                  delay: appearStagger(3),
                  child: _GlanceTile(
                    width: tileWidth,
                    maxHeight: maxH,
                    icon: Icons.person_pin_outlined,
                    label: 'Directed to you',
                    count: stats.directedToYouPending,
                  ),
                ),
              ],
            );
          },
        ),
        if (stats.urgentPending > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.priority_high, size: 18, color: scheme.error),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '${stats.urgentPending} urgent waiting',
                  style: context.text.labelLarge?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (stats.active > 0) ...[
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.go('/vet/active'),
              icon: const Icon(Icons.assignment_outlined, size: 18),
              label: Text(
                stats.active == 1
                    ? 'Open active case'
                    : 'Open ${stats.active} active cases',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _GlanceTile extends StatelessWidget {
  const _GlanceTile({
    required this.width,
    required this.maxHeight,
    required this.icon,
    required this.label,
    required this.count,
  });

  final double width;
  final double maxHeight;
  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Semantics(
      label: '$label, $count',
      child: SizedBox(
        width: width,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Card(
            elevation: 0,
            color: scheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxs),
                          child: Icon(icon, color: scheme.primary, size: 20),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AnimatedCount(
                        value: count,
                        format: (n) => NumberFormat.decimalPattern().format(n),
                        style: context.text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
