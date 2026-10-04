import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../domain/vet_inbox_stats.dart';

class VetRequestsStatsPanel extends StatelessWidget {
  const VetRequestsStatsPanel({required this.stats, super.key});

  final VetInboxStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Today at a glance',
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossCount = width >= 360 ? 2 : 1;
                return GridView.count(
                  crossAxisCount: crossCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: crossCount == 2 ? 2.4 : 3.2,
                  children: [
                    _StatCell(
                      label: 'New requests',
                      value: stats.pending,
                      icon: Icons.inbox_outlined,
                      color: scheme.tertiary,
                    ),
                    _StatCell(
                      label: 'Your active cases',
                      value: stats.active,
                      icon: Icons.assignment_outlined,
                      color: scheme.primary,
                    ),
                    _StatCell(
                      label: 'Visits in progress',
                      value: stats.inProgress,
                      icon: Icons.directions_walk_outlined,
                      color: scheme.primary,
                    ),
                    _StatCell(
                      label: 'Directed to you',
                      value: stats.directedToYouPending,
                      icon: Icons.person_pin_outlined,
                      color: scheme.secondary,
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
                  const SizedBox(width: 6),
                  Text(
                    '${stats.urgentPending} urgent waiting',
                    style: context.text.labelLarge?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value',
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: context.text.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VetRequestsQuickActions extends StatelessWidget {
  const VetRequestsQuickActions({
    required this.stats,
    required this.onRefresh,
    super.key,
  });

  final VetInboxStats stats;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _QuickActionButton(
          icon: Icons.assignment_outlined,
          label: stats.active > 0
              ? 'Active (${stats.active})'
              : 'Active cases',
          onTap: () => context.go('/vet/active'),
        ),
        _QuickActionButton(
          icon: Icons.map_outlined,
          label: 'Request map',
          onTap: () => context.go('/vet/map'),
        ),
        _QuickActionButton(
          icon: Icons.refresh,
          label: 'Refresh',
          onTap: onRefresh,
        ),
        _QuickActionButton(
          icon: Icons.my_location_outlined,
          label: 'Update GPS',
          onTap: () => context.go('/vet/more'),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
