import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/tab_empty_state.dart';
import '../domain/vet_case_workflow.dart';
import '../domain/vet_incident_detail.dart';
import 'vet_case_status_handler.dart';
import 'vet_incident_detail_screen.dart';
import 'vet_inbox_providers.dart';
import 'vet_request_tile.dart';

class VetActiveScreen extends ConsumerWidget {
  const VetActiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxAsync = ref.watch(vetInboxProvider);
    final vetUserId = ref.watch(authUserIdProvider).value;

    Future<void> refresh() async {
      ref.invalidate(vetInboxProvider);
      await ref.read(vetInboxProvider.future);
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ContentFrame(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            ContentFrame.scrollBottomInset(context),
          ),
          children: [
            Text(
              'Accepted cases — start the visit, then mark complete when done.',
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
              error: (e, _) => TabEmptyState(
                icon: Icons.error_outline,
                title: 'Could not load',
                message: '$e',
                actionLabel: 'Retry',
                onAction: refresh,
              ),
              data: (items) {
                if (vetUserId == null) {
                  return const _EmptyActive();
                }
                final active = items
                    .where((i) => vetInboxItemIsActive(i, vetUserId))
                    .toList(growable: false);
                if (active.isEmpty) {
                  return const _EmptyActive();
                }
                return Column(
                  children: [
                    for (final item in active) ...[
                      VetRequestTile(
                        item: item,
                        onOpenDetail: () => openVetIncidentDetail(
                          context,
                          VetIncidentDetail.fromInbox(item),
                        ),
                        onMarkInProgress: item.status == 'accepted'
                            ? () => applyVetCaseAction(
                                  context: context,
                                  ref: ref,
                                  requestId: item.id,
                                  action: VetCaseAction.startVisit,
                                )
                            : null,
                        onMarkComplete: item.status == 'in_progress'
                            ? () => applyVetCaseAction(
                                  context: context,
                                  ref: ref,
                                  requestId: item.id,
                                  action: VetCaseAction.markComplete,
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
}

class _EmptyActive extends StatelessWidget {
  const _EmptyActive();

  @override
  Widget build(BuildContext context) {
    return TabEmptyState(
      icon: Icons.assignment_outlined,
      title: 'No active cases',
      message:
          'Accept a request from the Requests tab, then start the visit here.',
    );
  }
}
