import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/di/providers.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/layout/layout_scope.dart';
import '../../../app/layout/two_pane.dart';
import '../../../app/shell/tab_scroll_registry.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../auth/domain/user_profile.dart';
import '../../home/presentation/farm_profile_banner.dart';
import 'today_greeting_card.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  static const _tabIndex = 0;

  final _scrollController = ScrollController();
  TabScrollRegistry? _tabScrollRegistryNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _tabScrollRegistryNotifier = ref.read(tabScrollRegistryProvider.notifier);
      _tabScrollRegistryNotifier!.register(
        _tabIndex,
        () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _tabScrollRegistryNotifier?.unregister(_tabIndex);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(syncEngineProvider).syncOnce(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    final greeting = _greeting(profile);
    final showFarmProfileBanner = ref.watch(farmProfileIncompleteProvider);
    final layout = context.layout;
    final bottomInset = ContentFrame.scrollBottomInset(context);
    final horizontal = layout.margin;
    final topInset = MediaQuery.viewPaddingOf(context).top;
    final useTwoPane = layout.useTwoPane;

    final banner = showFarmProfileBanner
        ? const Column(
            children: [
              FarmProfileBanner(),
              SizedBox(height: AppSpacing.sm),
            ],
          )
        : const SizedBox.shrink();

    final needsAttention = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SectionHeader(
          title: 'Needs attention',
          subtitle: 'Overdue and due-today tasks',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _NeedsAttentionList(),
      ],
    );

    final atAGlance = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SectionHeader(
          title: 'At a glance',
          subtitle: 'Live counts will appear as you add data.',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _MetricGrid(),
      ],
    );

    if (useTwoPane) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        edgeOffset: 8,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    layout.hideTabRootAppBar ? topInset + AppSpacing.xs : AppSpacing.xs,
                    horizontal,
                    0,
                  ),
                  child: banner,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: _InlineGreetingLine(greeting: greeting),
                ),
                SizedBox(height: layout.gutter),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontal),
                    child: TwoPane(
                      primary: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: bottomInset),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: needsAttention,
                      ),
                      secondary: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: bottomInset),
                        child: atAGlance,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      edgeOffset: 8,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontal,
              AppSpacing.xs,
              horizontal,
              bottomInset,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                banner,
                TodayGreetingCard(
                  greeting: greeting,
                  subtitle:
                      "Here's what needs attention on your farm today.",
                  compact: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                needsAttention,
                const SizedBox(height: AppSpacing.lg),
                atAGlance,
                const SizedBox(height: AppSpacing.lg),
                const _SectionHeader(title: 'Quick actions'),
                const SizedBox(height: AppSpacing.sm),
                _QuickActions(
                  onSync: () =>
                      ref.read(syncEngineProvider).syncOnce(force: true),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(UserProfile? profile) {
    final hour = DateTime.now().hour;
    final period = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    if (profile == null) {
      return period;
    }
    return '$period, ${profile.displayName}';
  }
}

class _InlineGreetingLine extends StatelessWidget {
  const _InlineGreetingLine({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.waving_hand_rounded,
          size: 20,
          color: context.colors.logoTint,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            greeting,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle!,
            style: context.text.bodySmall?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _MetricGrid extends ConsumerWidget {
  const _MetricGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = context.layout;
    final cols = layout.statColumns;
    final active = ref.watch(activeBatchCountProvider).value ?? 0;
    final dueWeek = ref.watch(dueThisWeekCountProvider).value ?? 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = AppSpacing.sm * (cols - 1);
        final tileWidth = (constraints.maxWidth - gap) / cols;

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _MetricTile(
              width: tileWidth,
              icon: Icons.view_module_outlined,
              label: 'Active batches',
              value: '$active',
            ),
            _MetricTile(
              width: tileWidth,
              icon: Icons.vaccines_outlined,
              label: 'Due this week',
              value: '$dueWeek',
            ),
            _MetricTile(
              width: tileWidth,
              icon: Icons.restaurant_outlined,
              label: 'Feed stock',
              value: '—',
            ),
            _MetricTile(
              width: tileWidth,
              icon: Icons.favorite_outline,
              label: 'Health alerts',
              value: '—',
            ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final maxH = context.layout.statCardMaxHeight;

    return Semantics(
      label: '$label, $value',
      child: SizedBox(
        width: width,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
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
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxs),
                          child: Icon(icon, color: scheme.primary, size: 20),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        value,
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

class _NeedsAttentionList extends ConsumerWidget {
  const _NeedsAttentionList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(needsAttentionTasksProvider);
    return tasksAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const _TasksEmptyState(),
      data: (tasks) {
        if (tasks.isEmpty) {
          return const _TasksEmptyState();
        }
        return Column(
          children: tasks.take(8).map((task) {
            final label = _taskLabel(task.stepSnapshot, task.stepId);
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: ListTile(
                leading: Icon(
                  Icons.vaccines_outlined,
                  color: context.colors.logoTint,
                ),
                title: Text(label),
                subtitle: Text(DateFormat.yMMMd().format(task.dueOn.toUtc())),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => BatchDetailRoute(batchId: task.batchId).push(context),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _taskLabel(String? snapshot, String fallback) {
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
}

class _TasksEmptyState extends StatelessWidget {
  const _TasksEmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.successContainer.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(
                  Icons.task_alt_rounded,
                  color: colors.onSuccessContainer,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nothing due today',
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'When vaccinations or chores are scheduled, they will show up here.',
                    style: context.text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onSync});

  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: onSync,
            icon: const Icon(Icons.sync_rounded),
            label: const Text('Sync now'),
          ),
        ),
      ],
    );
  }
}
