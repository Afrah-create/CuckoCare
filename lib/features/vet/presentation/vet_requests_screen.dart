import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/tab_empty_state.dart';
import '../../../core/error/user_messages.dart';
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
  _VetRequestFilter _filter = _VetRequestFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(vetInboxProvider);
    });
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

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ContentFrame(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: ContentFrame.scrollBottomInset(context),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      online
                          ? 'Open farmer requests waiting for a vet.'
                          : 'Offline — pull down to refresh when online.',
                      style: context.text.bodyMedium?.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            if (!online)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: MaterialBanner(
                  content: const Text(
                    'Connect to the internet to load live requests.',
                  ),
                  leading: const Icon(Icons.cloud_off_outlined),
                  actions: [
                    TextButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              ),
            ...inboxAsync.when(
              loading: () => [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (e, _) => [
                TabEmptyState(
                  icon: Icons.error_outline,
                  title: 'Could not load',
                  message: userMessageForError(e),
                  actionLabel: 'Try again',
                  onAction: _refresh,
                ),
              ],
              data: (items) => _inboxListChildren(
                context,
                items: items,
                vetUserId: vetUserId,
              ),
            ),
          ],
        ),
      ),
    );
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
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: VetRequestsStatsPanel(stats: stats),
      ),
      const SizedBox(height: AppSpacing.md),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: VetRequestsQuickActions(
          stats: stats,
          onRefresh: _refresh,
        ),
      ),
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
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Queue',
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FilterRow(
              selected: effectiveFilter,
              showUrgent: urgentCount > 0,
              onSelected: (f) => setState(() => _filter = f),
            ),
          ],
        ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: VetRequestTile(
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
      spacing: 8,
      runSpacing: 8,
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
    final scheme = context.scheme;
    return Material(
      color: selected
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: context.text.labelLarge?.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
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
      title: hasStats ? 'No new requests' : 'Sign in required',
      message: hasStats
          ? 'Stats above reflect your inbox. New farmer incidents appear here '
              'when they notify a vet and sync completes.'
          : 'Could not load your vet account. Pull to refresh or sign in again.',
    );
  }
}
