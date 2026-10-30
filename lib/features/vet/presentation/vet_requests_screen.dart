import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/shell/tab_scroll_registry.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/layout/layout_scope.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/offline_notice.dart';
import '../../../app/widgets/states/pull_to_refresh.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../app/widgets/tab_empty_state.dart';
import '../../../core/error/failure_mapper.dart';
import '../../today/presentation/today_greeting_card.dart';
import '../data/vet_inbox_repository.dart';
import '../domain/vet_case_workflow.dart';
import '../domain/vet_incident_detail.dart';
import 'vet_case_status_handler.dart';
import 'vet_incident_detail_screen.dart';
import '../domain/vet_inbox_stats.dart';
import 'vet_inbox_providers.dart';
import 'vet_request_tile.dart';
import 'vet_requests_dashboard.dart';

enum _VetRequestFilter { all, newOnly, directed, urgent }

class VetRequestsScreen extends ConsumerStatefulWidget {
  const VetRequestsScreen({super.key});

  @override
  ConsumerState<VetRequestsScreen> createState() => _VetRequestsScreenState();
}

class _VetRequestsScreenState extends ConsumerState<VetRequestsScreen> {
  static const _tabIndex = 0;

  _VetRequestFilter _filter = _VetRequestFilter.all;
  final _scrollController = ScrollController();
  TabScrollRegistry? _tabScrollRegistryNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(vetInboxProvider);
      if (!mounted) {
        return;
      }
      _tabScrollRegistryNotifier = ref.read(tabScrollRegistryProvider.notifier);
      _tabScrollRegistryNotifier!.register(_tabIndex, () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _tabScrollRegistryNotifier?.unregister(_tabIndex);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(vetInboxProvider);
    await ref.read(vetInboxProvider.future);
  }

  List<VetInboxItem> _pendingForVet(
    List<VetInboxItem> items,
    String vetUserId,
  ) {
    final pending = items
        .where((i) => vetInboxItemIsPending(i, vetUserId))
        .toList(growable: false);
    pending.sort((a, b) {
      final aScore = _sortScore(a, vetUserId);
      final bScore = _sortScore(b, vetUserId);
      if (aScore != bScore) {
        return bScore.compareTo(aScore);
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return pending;
  }

  int _sortScore(VetInboxItem item, String vetUserId) {
    var score = 0;
    if (item.priority == 'urgent') {
      score += 100;
    }
    if (item.requestedVetUserId == vetUserId) {
      score += 50;
    }
    if (item.isDirectedRequest) {
      score += 10;
    }
    return score;
  }

  List<VetInboxItem> _applyFilter(
    List<VetInboxItem> pending,
    String vetUserId,
    _VetRequestFilter filter,
  ) {
    return switch (filter) {
      _VetRequestFilter.all => pending,
      _VetRequestFilter.newOnly => pending
          .where((i) => i.status == 'submitted')
          .toList(growable: false),
      _VetRequestFilter.directed => pending
          .where((i) => i.requestedVetUserId == vetUserId)
          .toList(growable: false),
      _VetRequestFilter.urgent =>
        pending.where((i) => i.priority == 'urgent').toList(growable: false),
    };
  }

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(connectivityOnlineProvider).value ?? true;
    final inboxAsync = ref.watch(vetInboxProvider);
    final vetUserId = ref.watch(authUserIdProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    final layout = context.layout;
    final horizontal = layout.margin;
    final greeting = _vetGreeting(profile?.displayName);

    return AppPage(
      primary: false,
      frame: false,
      body: PullToRefresh(
        online: online,
        onSync: _refresh,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            horizontal,
            AppSpacing.xs,
            horizontal,
            ContentFrame.scrollBottomInset(context),
          ),
          children: [
            TodayGreetingCard(
              greeting: greeting,
              subtitle: online
                  ? 'Farmer requests waiting for you.'
                  : 'You are offline. Pull down to refresh when you are back.',
            ),
            const SizedBox(height: AppSpacing.md),
            if (!online) ...[
              const OfflineNotice(),
              const SizedBox(height: AppSpacing.md),
            ],
            AsyncStateView<List<VetInboxItem>>(
              expand: false,
              value: inboxAsync,
              onRetry: _refresh,
              skeleton: const ListSkeleton(count: 3, scrollable: false),
              error: (error, _) => ErrorState(
                failure: FailureMapper.mapObject(error),
                onRetry: _refresh,
              ),
              builder: (items) => Column(
                children: _inboxListChildren(
                  context,
                  items: items,
                  vetUserId: vetUserId,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _vetGreeting(String? name) {
    final hour = DateTime.now().hour;
    final period = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    if (name == null || name.isEmpty || name == 'Farmer') {
      return period;
    }
    return '$period, $name';
  }

  List<Widget> _inboxListChildren(
    BuildContext context, {
    required List<VetInboxItem> items,
    required String? vetUserId,
  }) {
    if (vetUserId == null) {
      return const [_InboxEmptyBody(hasStats: false)];
    }

    final stats = VetInboxStats.fromItems(items, vetUserId);
    final pending = _pendingForVet(items, vetUserId);
    final urgentCount = stats.urgentPending;
    final effectiveFilter =
        _filter == _VetRequestFilter.urgent && urgentCount == 0
            ? _VetRequestFilter.all
            : _filter;
    final filtered = _applyFilter(pending, vetUserId, effectiveFilter);

    final children = <Widget>[
      VetRequestsStatsPanel(stats: stats),
      const SizedBox(height: AppSpacing.lg),
    ];

    if (pending.isEmpty) {
      children.add(
        _InboxEmptyBody(
          hasStats: true,
          activeCount: stats.active,
          inProgressCount: stats.inProgress,
        ),
      );
      return children;
    }

    children.addAll([
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Needs attention',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'New and waiting farmer requests',
            style: context.text.bodySmall?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _FilterRow(
            selected: effectiveFilter,
            showUrgent: urgentCount > 0,
            onSelected: (f) => setState(() => _filter = f),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
    ]);

    if (filtered.isEmpty) {
      children.add(
        TabEmptyState(
          icon: Icons.filter_list_off,
          title: 'No matches',
          message: 'Try another filter or refresh the list.',
          actionLabel: 'Show all',
          onAction: () => setState(() => _filter = _VetRequestFilter.all),
        ),
      );
      return children;
    }

    for (final item in filtered) {
      children.add(
        VetRequestTile(
            item: item,
            onOpenDetail: () => openVetIncidentDetail(
              context,
              VetIncidentDetail.fromInbox(item),
            ),
            onAccept: () => applyVetCaseAction(
              context: context,
              ref: ref,
              requestId: item.id,
              action: VetCaseAction.accept,
            ),
            onDecline: () => applyVetCaseAction(
              context: context,
              ref: ref,
              requestId: item.id,
              action: VetCaseAction.decline,
            ),
          ),
      );
      children.add(const SizedBox(height: AppSpacing.sm));
    }
    return children;
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selected,
    required this.showUrgent,
    required this.onSelected,
  });

  final _VetRequestFilter selected;
  final bool showUrgent;
  final ValueChanged<_VetRequestFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        _FilterChip(
          label: 'All',
          selected: selected == _VetRequestFilter.all,
          onTap: () => onSelected(_VetRequestFilter.all),
        ),
        _FilterChip(
          label: 'New',
          selected: selected == _VetRequestFilter.newOnly,
          onTap: () => onSelected(_VetRequestFilter.newOnly),
        ),
        _FilterChip(
          label: 'For you',
          selected: selected == _VetRequestFilter.directed,
          onTap: () => onSelected(_VetRequestFilter.directed),
        ),
        if (showUrgent)
          _FilterChip(
            label: 'Urgent',
            selected: selected == _VetRequestFilter.urgent,
            onTap: () => onSelected(_VetRequestFilter.urgent),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _InboxEmptyBody extends StatelessWidget {
  const _InboxEmptyBody({
    this.hasStats = false,
    this.activeCount = 0,
    this.inProgressCount = 0,
  });

  final bool hasStats;
  final int activeCount;
  final int inProgressCount;

  @override
  Widget build(BuildContext context) {
    if (hasStats && activeCount > 0) {
      return TabEmptyState(
        icon: Icons.check_circle_outline,
        title: 'Queue is clear',
        message: inProgressCount > 0
            ? 'No new requests right now. You have $activeCount active '
                'case${activeCount == 1 ? '' : 's'} ($inProgressCount in progress).'
            : 'No new requests right now. You have $activeCount active '
                'case${activeCount == 1 ? '' : 's'} waiting to start.',
        actionLabel: 'Open Active',
        onAction: () => context.go('/vet/active'),
      );
    }

    return TabEmptyState(
      icon: Icons.inbox_outlined,
      title: hasStats ? 'No requests right now' : 'Sign in required',
      message: hasStats
          ? 'New farmer requests will show up here.'
          : 'Pull to refresh, or sign in again.',
    );
  }
}
