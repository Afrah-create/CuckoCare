import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/error/result.dart';
import 'vet_inbox_providers.dart';
import 'vet_request_tile.dart';

class VetRequestsScreen extends ConsumerWidget {
  const VetRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final inboxAsync = ref.watch(vetInboxProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(vetInboxProvider);
        await ref.read(vetInboxProvider.future);
      },
      child: ContentFrame(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: ContentFrame.scrollBottomInset(context),
          ),
          children: [
            _HeroHeader(displayName: profile?.displayName),
            const SizedBox(height: AppSpacing.lg),
            inboxAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => _InboxError(
                message: '$e',
                onRetry: () => ref.invalidate(vetInboxProvider),
              ),
              data: (items) {
                final pending =
                    items.where(vetInboxItemIsPending).toList(growable: false);
                if (pending.isEmpty) {
                  return const _EmptyInbox();
                }
                return Column(
                  children: [
                    for (final item in pending) ...[
                      VetRequestTile(
                        item: item,
                        onAccept: () => _accept(context, ref, item.id),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
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
  const _HeroHeader({this.displayName});

  final String? displayName;

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
          Text(
            greeting,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Review new assistance requests from farmers in your area.',
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
            'No new requests',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'When a farmer asks for help, it will show up here.',
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
