import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../domain/vet_incident_filters.dart';
import 'vet_case_status_handler.dart';
import 'vet_incident_detail_screen.dart';
import 'vet_incident_filter_bar.dart';
import 'vet_inbox_providers.dart';
import 'vet_request_tile.dart';

class VetActiveScreen extends ConsumerStatefulWidget {
  const VetActiveScreen({super.key});

  @override
  ConsumerState<VetActiveScreen> createState() => _VetActiveScreenState();
}

class _VetActiveScreenState extends ConsumerState<VetActiveScreen> {
  VetIncidentFilters _filters = const VetIncidentFilters();

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

  void _openRequests() {
    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell != null) {
      shell.goBranch(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inboxAsync = ref.watch(vetInboxProvider);
    final vetUserId = ref.watch(authUserIdProvider).value;
    final layout = context.layout;
    final online = ref.watch(connectivityOnlineProvider).value ?? true;

    return AppPage(
      primary: false,
      frame: false,
      body: PullToRefresh(
        onSync: _refresh,
        online: online,
        child: AsyncStateView(
          value: inboxAsync,
          onRetry: _refresh,
          skeleton: const ListSkeleton(count: 3),
          error: (error, _) => ErrorState(
            failure: FailureMapper.mapObject(error),
            onRetry: _refresh,
          ),
          builder: (items) {
            if (vetUserId == null) {
              return const ListSkeleton(count: 3);
            }
            final active = items
                .where((i) => vetInboxItemIsActive(i, vetUserId))
                .toList(growable: false);
            final filtered = active
                .where(
                  (i) => _filters.matches(
                    serviceType: i.serviceType,
                    symptoms: i.symptoms,
                  ),
                )
                .toList(growable: false);
            if (active.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  SizedBox(
                    height: (MediaQuery.sizeOf(context).height - 280)
                        .clamp(360.0, 720.0),
                    child: TabEmptyState(
                      icon: Icons.assignment_outlined,
                      title: 'No visits yet',
                      message:
                          'Accept a request and it will land here. You can chat with the farmer, then start the visit when you are on the farm.',
                      actionLabel: 'Go to Requests',
                      onAction: _openRequests,
                    ),
                  ),
                ],
              );
            }

            final accepted = active.where((i) => i.status == 'accepted').length;
            final inProgress =
                active.where((i) => i.status == 'in_progress').length;
            final presentSymptoms = VetIncidentFilters.symptomsPresent(
              active.map((i) => i.symptoms),
            );
            final subtitle = [
              if (accepted > 0)
                '$accepted waiting to start',
              if (inProgress > 0) '$inProgress in progress',
            ].join(' · ');

            return ListView(
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
                  'Your cases',
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle.isEmpty
                      ? 'Message the farmer, then start the visit when you arrive.'
                      : subtitle,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                VetIncidentFilterBar(
                  value: _filters,
                  symptoms: presentSymptoms,
                  onChanged: (next) => setState(() => _filters = next),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  TabEmptyState(
                    icon: Icons.filter_list_off,
                    title: 'No matches',
                    message: 'Try another symptom or service filter.',
                    actionLabel: 'Show all',
                    onAction: () => setState(
                      () => _filters = const VetIncidentFilters(),
                    ),
                  )
                else ...[
                  for (final item in filtered) ...[
                    VetRequestTile(
                      item: item,
                      onOpenDetail: () => openVetIncidentDetail(
                        context,
                        VetIncidentDetail.fromInbox(item),
                      ),
                      onMessage: () => openVetCaseMessages(
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
              ],
            );
          },
        ),
      ),
    );
  }
}
