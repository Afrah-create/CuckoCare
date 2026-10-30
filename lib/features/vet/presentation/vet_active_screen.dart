import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/layout/layout_scope.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/pull_to_refresh.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../app/widgets/tab_empty_state.dart';
import '../../../core/error/failure_mapper.dart';
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

    final layout = context.layout;
    final online = ref.watch(connectivityOnlineProvider).value ?? true;

    return AppPage(
      primary: false,
      frame: false,
      body: PullToRefresh(
      onSync: refresh,
      online: online,
      child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            layout.margin,
            AppSpacing.xs,
            layout.margin,
            ContentFrame.scrollBottomInset(context),
          ),
          children: [
            Text(
              'Needs attention',
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Accepted cases — start the visit, then mark complete when done.',
              style: context.text.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AsyncStateView(
              expand: false,
              value: inboxAsync,
              onRetry: refresh,
              skeleton: const ListSkeleton(count: 3, scrollable: false),
              error: (error, _) => ErrorState(
                failure: FailureMapper.mapObject(error),
                onRetry: refresh,
              ),
              builder: (items) {
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
