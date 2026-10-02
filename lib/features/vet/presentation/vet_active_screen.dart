import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/error/result.dart';
import 'vet_inbox_providers.dart';
import 'vet_request_tile.dart';

class VetActiveScreen extends ConsumerWidget {
  const VetActiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            Text(
              'Cases you accepted or are working on.',
              style: context.text.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            inboxAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(
                'Could not load cases: $e',
                style: context.text.bodyMedium?.copyWith(
                  color: context.scheme.error,
                ),
              ),
              data: (items) {
                final active =
                    items.where(vetInboxItemIsActive).toList(growable: false);
                if (active.isEmpty) {
                  return const _EmptyActive();
                }
                return Column(
                  children: [
                    for (final item in active) ...[
                      VetRequestTile(
                        item: item,
                        onMarkInProgress: item.status == 'accepted'
                            ? () => _setStatus(
                                  context,
                                  ref,
                                  item.id,
                                  'in_progress',
                                )
                            : null,
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

  Future<void> _setStatus(
    BuildContext context,
    WidgetRef ref,
    String requestId,
    String status,
  ) async {
    final result = await ref.read(vetInboxRepositoryProvider).setRequestStatus(
          requestId: requestId,
          status: status,
        );
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case Success():
        ref.invalidate(vetInboxProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked in progress')),
        );
      case Error(failure: final f):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
    }
  }
}

class _EmptyActive extends StatelessWidget {
  const _EmptyActive();

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 56,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No active cases',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Accept a request from the Requests tab to see it here.',
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
