import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'skeleton.dart';

class TodaySkeleton extends StatelessWidget {
  const TodaySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonScope(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonLine(widthFactor: 0.42, height: 18),
          SizedBox(height: AppSpacing.xs),
          SkeletonLine(widthFactor: 0.66, height: 12),
          SizedBox(height: AppSpacing.lg),
          _StatRow(),
          SizedBox(height: AppSpacing.lg),
          SkeletonLine(widthFactor: 0.34, height: 16),
          SizedBox(height: AppSpacing.sm),
          SkeletonListTile(lineWidth: 0.58),
          SkeletonListTile(lineWidth: 0.74),
          SkeletonListTile(lineWidth: 0.5),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: SkeletonStatTile()),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: SkeletonStatTile()),
      ],
    );
  }
}

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({this.count = 4, this.scrollable = true, super.key});

  final int count;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      const SkeletonLine(widthFactor: 0.32, height: 16),
      const SizedBox(height: AppSpacing.md),
      for (var i = 0; i < count; i++)
        SkeletonListTile(lineWidth: 0.48 + (i % 3) * 0.1),
    ];
    if (!scrollable) {
      return SkeletonScope(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: tiles,
        ),
      );
    }
    return SkeletonScope(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: tiles,
      ),
    );
  }
}

class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonScope(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonDetailHeader(),
            SizedBox(height: AppSpacing.lg),
            SkeletonListTile(),
            SkeletonListTile(lineWidth: 0.5),
            SkeletonListTile(lineWidth: 0.66),
          ],
        ),
      ),
    );
  }
}

class FormSkeleton extends StatelessWidget {
  const FormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonScope(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonLine(widthFactor: 0.3, height: 14),
            SizedBox(height: AppSpacing.sm),
            SkeletonBlock(height: 52, radius: AppSpacing.radiusMd),
            SizedBox(height: AppSpacing.md),
            SkeletonLine(widthFactor: 0.24, height: 14),
            SizedBox(height: AppSpacing.sm),
            SkeletonBlock(height: 52, radius: AppSpacing.radiusMd),
            SizedBox(height: AppSpacing.lg),
            SkeletonBlock(height: 48, radius: AppSpacing.radiusMd),
          ],
        ),
      ),
    );
  }
}

class SettingsSkeleton extends StatelessWidget {
  const SettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonScope(
      child: Column(
        children: [
          SkeletonCard(lines: [0.4, 0.7]),
          SkeletonCard(lines: [0.55, 0.36]),
          SkeletonCard(lines: [0.48, 0.62]),
        ],
      ),
    );
  }
}

class MapSkeleton extends StatelessWidget {
  const MapSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonScope(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SkeletonBlock(radius: AppSpacing.radiusLg),
            ),
            SizedBox(height: AppSpacing.md),
            SkeletonLine(widthFactor: 0.4, height: 14),
            SizedBox(height: AppSpacing.xs),
            SkeletonLine(widthFactor: 0.62, height: 12),
          ],
        ),
      ),
    );
  }
}

class PhotoStripSkeleton extends StatelessWidget {
  const PhotoStripSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonScope(
      child: SizedBox(
        height: 112,
        child: Row(
          children: [
            SkeletonBlock(width: 112, height: 112, radius: 14),
            SizedBox(width: AppSpacing.sm),
            SkeletonBlock(width: 112, height: 112, radius: 14),
          ],
        ),
      ),
    );
  }
}
