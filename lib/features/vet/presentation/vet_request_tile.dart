import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../data/vet_inbox_repository.dart';
import '../domain/vet_case_workflow.dart';

class VetRequestTile extends StatelessWidget {
  const VetRequestTile({
    required this.item,
    this.onAccept,
    this.onDecline,
    this.onMarkInProgress,
    this.onMarkComplete,
    this.onOpenDetail,
    super.key,
  });

  final VetInboxItem item;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onMarkInProgress;
  final VoidCallback? onMarkComplete;
  final VoidCallback? onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.MMMd().add_jm().format(item.createdAt.toLocal());
    final scheme = context.scheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: onOpenDetail,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(
                    _serviceIcon(item.serviceType),
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.summary ?? _serviceLabel(item.serviceType),
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: context.text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.farmLocationLabel,
                        style: context.text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (item.distanceKm != null)
                        Text(
                          '${item.distanceKm!.toStringAsFixed(1)} km from you',
                          style: context.text.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                Flexible(
                  child: _StatusChip(
                    status: item.status,
                    priority: item.priority,
                  ),
                ),
              ],
            ),
            if (item.isDirectedRequest) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Requested you specifically',
                style: context.text.labelMedium?.copyWith(
                  color: scheme.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (item.affectedBirdCount != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('Birds affected: ${item.affectedBirdCount}'),
            ],
            if (item.symptoms.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in item.symptoms)
                    Chip(
                      label: Text(s),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            if (item.farmerNotes != null && item.farmerNotes!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.farmerNotes!.trim(),
                style: context.text.bodyMedium,
              ),
            ],
            if (item.photoObjectKeys.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.photo_library_outlined, size: 18, color: scheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${item.photoObjectKeys.length} photo${item.photoObjectKeys.length == 1 ? '' : 's'} · tap to view',
                    style: context.text.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            if (item.shareLocation) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Farm location shared',
                    style: context.text.labelLarge?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ],
            if (onAccept != null ||
                onDecline != null ||
                onMarkInProgress != null ||
                onMarkComplete != null) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (onDecline != null)
                    TextButton(
                      onPressed: onDecline,
                      child: const Text('Decline'),
                    ),
                  if (onMarkInProgress != null)
                    FilledButton.tonal(
                      onPressed: onMarkInProgress,
                      child: const Text('Start visit'),
                    ),
                  if (onMarkComplete != null)
                    FilledButton(
                      onPressed: onMarkComplete,
                      child: const Text('Mark complete'),
                    ),
                  if (onAccept != null)
                    FilledButton.tonal(
                      onPressed: onAccept,
                      child: const Text('Accept'),
                    ),
                ],
              ),
            ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _serviceIcon(String type) => switch (type) {
        'farm_visit' => Icons.agriculture_outlined,
        'consultation' => Icons.medical_services_outlined,
        _ => Icons.healing_outlined,
      };

  static String _serviceLabel(String type) => switch (type) {
        'consultation' => 'Consultation',
        'farm_visit' => 'Farm visit',
        _ => 'Veterinary assistance',
      };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.priority});

  final String status;
  final String priority;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final label = _shortStatusLabel(status);
    final color = switch (status) {
      'submitted' || 'received' => scheme.tertiary,
      'accepted' || 'in_progress' => scheme.primary,
      'completed' => scheme.outline,
      'declined' || 'cancelled' => scheme.error,
      _ => scheme.outline,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textAlign: TextAlign.end,
            style: context.text.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (priority == 'urgent') ...[
          const SizedBox(height: 4),
          Text(
            'Urgent',
            style: context.text.labelSmall?.copyWith(
              color: scheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  static String _shortStatusLabel(String status) => switch (status) {
        'submitted' => 'New',
        'received' => 'Received',
        'accepted' => 'Accepted',
        'in_progress' => 'In progress',
        'completed' => 'Done',
        'declined' => 'Declined',
        _ => vetRequestStatusLabel(status),
      };
}
