import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/error/result.dart';
import '../../../core/error/user_messages.dart';
import '../domain/vet_incident_detail.dart';
import 'vet_incident_detail_screen.dart';
import 'vet_inbox_providers.dart';
import 'vet_request_tile.dart';

class VetRequestsScreen extends ConsumerStatefulWidget {
  const VetRequestsScreen({super.key});

  @override
  ConsumerState<VetRequestsScreen> createState() => _VetRequestsScreenState();
}

class _VetRequestsScreenState extends ConsumerState<VetRequestsScreen> {
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

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
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
            _HeroHeader(
              displayName: profile?.displayName,
              online: online,
              onRefresh: _refresh,
            ),
            if (!online) ...[
              const SizedBox(height: AppSpacing.sm),
              MaterialBanner(
                content: const Text(
                  'You are offline. Connect to load live requests from farmers.',
                ),
                leading: const Icon(Icons.cloud_off_outlined),
                actions: [
                  TextButton(onPressed: _refresh, child: const Text('Retry')),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            inboxAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => _InboxError(
                message: userMessageForError(e),
                onRetry: _refresh,
              ),
              data: (items) {
                if (vetUserId == null) {
                  return const _EmptyInbox();
                }
                final pending = items
                    .where((i) => vetInboxItemIsPending(i, vetUserId))
                    .toList(growable: false);
                final activeOthers = items
                    .where((i) => vetInboxItemIsActive(i, vetUserId))
                    .toList(growable: false);

                if (pending.isEmpty && activeOthers.isEmpty) {
                  return const _EmptyInbox();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${pending.length + activeOthers.length} visible to you',
                      style: context.text.labelLarge?.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (pending.isNotEmpty) ...[
                      Text(
                        'New requests',
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final item in pending) ...[
                        VetRequestTile(
                          item: item,
                          onOpenDetail: () => openVetIncidentDetail(
                            context,
                            VetIncidentDetail.fromInbox(item),
                          ),
                          onAccept: () => _accept(context, ref, item.id),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                    if (activeOthers.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Already in progress',
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final item in activeOthers) ...[
                        VetRequestTile(
                          item: item,
                          onOpenDetail: () => openVetIncidentDetail(
                            context,
                            VetIncidentDetail.fromInbox(item),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                    if (pending.isEmpty && activeOthers.isEmpty)
                      const _EmptyInbox(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _accept(
    BuildContext context,
    WidgetRef ref,
    String requestId,
  ) async {
    final result = await ref.read(vetInboxRepositoryProvider).setRequestStatus(
          requestId: requestId,
          status: 'accepted',
        );
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case Success():
        ref.invalidate(vetInboxProvider);
        ref.invalidate(vetMapProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request accepted — see Active tab')),
        );
      case Error(failure: final f):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
    }
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    this.displayName,
    required this.online,
    required this.onRefresh,
  });

  final String? displayName;
  final bool online;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final greeting = displayName != null && displayName!.trim().isNotEmpty
        ? 'Hello, ${displayName!.trim()}'
        : 'Hello';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer,
            scheme.secondaryContainer.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  greeting,
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh inbox',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            online
                ? 'Live requests from farmers (pull to refresh).'
                : 'Offline — showing last loaded data when available.',
            style: context.text.bodyMedium?.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 56,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No open requests',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'When farmers request vet help on an incident, directed and open broadcast requests show here. Cases accepted by another vet are hidden.',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InboxError extends StatelessWidget {
  const _InboxError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(
              color: context.scheme.error,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
