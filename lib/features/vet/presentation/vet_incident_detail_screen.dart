import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/layout/page_layout.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../messaging/domain/messaging_rules.dart';
import '../../messaging/presentation/messaging_providers.dart';
import '../../messaging/presentation/unread_badge.dart';
import '../domain/vet_case_workflow.dart';
import '../domain/vet_incident_detail.dart';
import 'vet_case_status_handler.dart';
import 'vet_incident_photo_gallery.dart';

void openVetIncidentDetail(BuildContext context, VetIncidentDetail detail) {
  context.push('/vet/incident', extra: detail);
}

void openVetCaseMessages(BuildContext context, VetIncidentDetail detail) {
  CaseMessagesRoute(
    requestId: detail.requestId,
    farmId: detail.farmId,
    status: detail.status,
    priority: detail.priority,
    summary: detail.summary,
  ).push(context);
}

class VetIncidentDetailScreen extends ConsumerWidget {
  const VetIncidentDetailScreen({required this.detail, super.key});

  final VetIncidentDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.scheme;
    final vetUserId = ref.watch(authUserIdProvider).value;
    final isAssignedToMe =
        detail.assignedVetUserId == null || detail.assignedVetUserId == vetUserId;
    final actions = vetCaseActionsFor(
      status: detail.status,
      isAssignedToMe: isAssignedToMe,
    );
    final date =
        DateFormat.yMMMd().add_jm().format(detail.createdAt.toLocal());

    return AppPage(
      title: 'Incident',
      preset: PageLayout.reading,
      frame: false,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: scheme.primaryContainer.withValues(alpha: 0.45),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.summary,
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      label: vetRequestStatusLabel(detail.status),
                      color: scheme.primary,
                    ),
                    _Pill(label: _serviceLabel(detail.serviceType), color: scheme.secondary),
                    if (detail.priority == 'urgent')
                      _Pill(label: 'Urgent', color: scheme.error),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  date,
                  style: context.text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: 'Farm',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.farmLocationLabel,
                  style: context.text.bodyLarge,
                ),
                if (detail.distanceKm != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${detail.distanceKm!.toStringAsFixed(1)} km from you',
                    style: context.text.labelLarge?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ],
                if (detail.shareLocation)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, size: 18, color: scheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Location shared',
                          style: context.text.bodySmall?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (detail.isDirectedRequest)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      'This request was sent to you directly.',
                      style: context.text.bodySmall?.copyWith(
                        color: scheme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (detail.affectedBirdCount != null) ...[
            const SizedBox(height: AppSpacing.md),
            _Section(
              title: 'Impact',
              child: Text('${detail.affectedBirdCount} birds affected'),
            ),
          ],
          if (detail.symptoms.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _Section(
              title: 'Symptoms',
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in detail.symptoms)
                    Chip(
                      label: Text(s),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
          ],
          if (detail.farmerNotes != null &&
              detail.farmerNotes!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _Section(
              title: 'Farmer notes',
              child: Text(detail.farmerNotes!.trim()),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _MessagesEntry(detail: detail),
          const SizedBox(height: AppSpacing.md),
          VetIncidentPhotoGallery(photoObjectKeys: detail.photoObjectKeys),
          const SizedBox(height: AppSpacing.xl),
          if (actions.isNotEmpty)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final action in actions)
                  if (action == VetCaseAction.decline)
                    OutlinedButton(
                      onPressed: () => applyVetCaseAction(
                        context: context,
                        ref: ref,
                        requestId: detail.requestId,
                        action: action,
                        popAfterSuccess: true,
                      ),
                      child: Text(vetCaseActionLabel(action)),
                    )
                  else
                    FilledButton(
                      onPressed: () async {
                        await applyVetCaseAction(
                          context: context,
                          ref: ref,
                          requestId: detail.requestId,
                          action: action,
                          popAfterSuccess:
                              action == VetCaseAction.markComplete,
                        );
                        if (action == VetCaseAction.accept &&
                            context.mounted) {
                          CaseMessagesRoute(
                            requestId: detail.requestId,
                            farmId: detail.farmId,
                            status: 'accepted',
                            priority: detail.priority,
                            summary: detail.summary,
                          ).push(context);
                        }
                      },
                      child: Text(vetCaseActionLabel(action)),
                    ),
              ],
            ),
        ],
      ),
    );
  }

  static String _serviceLabel(String type) => switch (type) {
        'consultation' => 'Consultation',
        'farm_visit' => 'Farm visit',
        _ => 'Assistance',
      };
}

class _MessagesEntry extends ConsumerWidget {
  const _MessagesEntry({required this.detail});

  final VetIncidentDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(caseUnreadProvider(detail.requestId)).value ?? 0;
    final open = MessagingRules().isOpen(detail.status);
    final archived = MessagingRules().isArchived(detail.status);
    return Card(
      elevation: 0,
      color: context.scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.forum_outlined, color: context.scheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Chat with farmer',
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                UnreadBadge(count: unread),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              open
                  ? 'Keep advising until this case is complete.'
                  : archived
                      ? 'Read-only — this case is closed.'
                      : 'Accept the request to start chatting.',
              style: context.text.bodySmall?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.tonal(
              onPressed: () => openVetCaseMessages(context, detail),
              child: Text(open ? 'Open chat' : 'View messages'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.text.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.scheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.text.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
