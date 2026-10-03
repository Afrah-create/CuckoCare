import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/error/result.dart';
import '../domain/vet_incident_detail.dart';
import 'vet_incident_photo_gallery.dart';
import 'vet_inbox_providers.dart';

void openVetIncidentDetail(BuildContext context, VetIncidentDetail detail) {
  context.push('/vet/incident', extra: detail);
}

class VetIncidentDetailScreen extends ConsumerWidget {
  const VetIncidentDetailScreen({required this.detail, super.key});

  final VetIncidentDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.scheme;
    final date =
        DateFormat.yMMMd().add_jm().format(detail.createdAt.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident'),
      ),
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
                    _Pill(label: _statusLabel(detail.status), color: scheme.primary),
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
          VetIncidentPhotoGallery(photoObjectKeys: detail.photoObjectKeys),
          const SizedBox(height: AppSpacing.xl),
          if (detail.status == 'submitted' || detail.status == 'received')
            FilledButton(
              onPressed: () => _accept(context, ref),
              child: const Text('Accept request'),
            ),
        ],
      ),
    );
  }

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(vetInboxRepositoryProvider).setRequestStatus(
          requestId: detail.requestId,
          status: 'accepted',
        );
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case Success():
        ref.invalidate(vetInboxProvider);
        ref.invalidate(vetMapProvider);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request accepted')),
        );
      case Error(failure: final f):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
    }
  }

  static String _statusLabel(String status) => switch (status) {
        'submitted' => 'New',
        'received' => 'Received',
        'accepted' => 'Accepted',
        'in_progress' => 'In progress',
        _ => status,
      };

  static String _serviceLabel(String type) => switch (type) {
        'consultation' => 'Consultation',
        'farm_visit' => 'Farm visit',
        _ => 'Assistance',
      };
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
