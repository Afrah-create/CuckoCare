import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/tab_empty_state.dart';
import '../../../data_platform/db/app_database.dart';
import '../../health/data/health_repository.dart';

final farmerIncidentsProvider = StreamProvider<List<FarmerIncidentEntry>>((ref) {
  final farmId = ref.watch(primaryFarmProvider).value?.id;
  if (farmId == null) {
    return Stream.value(const []);
  }
  return ref.watch(healthRepositoryProvider).watchFarmIncidents(farmId);
});

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(farmerIncidentsProvider);

    return incidentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const TabEmptyState(
        icon: Icons.note_alt_outlined,
        title: 'Records',
        message: 'Could not load health records.',
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return const TabEmptyState(
            icon: Icons.note_alt_outlined,
            title: 'Records',
            message:
                'Batch health incidents and vet request status will appear here.',
          );
        }
        return ContentFrame(
          child: ListView.separated(
            padding: EdgeInsets.only(
              top: AppSpacing.md,
              bottom: ContentFrame.scrollBottomInset(context),
            ),
            itemCount: entries.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Text(
                  'Health incidents',
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                );
              }
              return _IncidentRecordCard(
                entry: entries[index - 1],
              );
            },
          ),
        );
      },
    );
  }
}

class _IncidentRecordCard extends ConsumerWidget {
  const _IncidentRecordCard({required this.entry});

  final FarmerIncidentEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = entry.record;
    final request = entry.vetRequest;
    final date = DateFormat.yMMMd().format(record.occurredOn.toLocal());
    final symptoms = (jsonDecode(record.symptomsJson) as List)
        .map((e) => e.toString())
        .where((s) => s.isNotEmpty)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.summary,
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${entry.batchName ?? 'Batch'} · $date',
              style: context.text.bodySmall?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            if (record.affectedBirdCount != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('Birds affected: ${record.affectedBirdCount}'),
            ],
            if (symptoms.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in symptoms)
                    Chip(
                      label: Text(s),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            if (request != null) ...[
              const SizedBox(height: AppSpacing.md),
              if (request.status == 'draft')
                _DraftVetRequestRow(
                  requestId: request.id,
                  onPublish: () async {
                    try {
                      await ref
                          .read(healthRepositoryProvider)
                          .publishDraftVetRequest(request.id);
                      ref.read(syncSchedulerProvider).notifyLocalWrite();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Vet notified — request will send when online.',
                            ),
                          ),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not notify vet. Try again.'),
                          ),
                        );
                      }
                    }
                  },
                )
              else
                _VetRequestStatusRow(request: request),
            ] else ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'No vet request linked (older record).',
                style: context.text.bodySmall?.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DraftVetRequestRow extends StatelessWidget {
  const _DraftVetRequestRow({
    required this.requestId,
    required this.onPublish,
  });

  final String requestId;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vet not notified yet',
            style: context.text.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This incident is saved on your device only.',
            style: context.text.bodySmall?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: onPublish,
              child: const Text('Notify a vet'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VetRequestStatusRow extends StatelessWidget {
  const _VetRequestStatusRow({required this.request});

  final VetAssistanceRequestRow request;

  @override
  Widget build(BuildContext context) {
    final status = request.status;
    final (label, color) = _statusStyle(context, status);
    final directed = request.requestedVetUserId != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vet assistance',
            style: context.text.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: context.text.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _serviceLabel(request.serviceType),
                style: context.text.bodySmall,
              ),
            ],
          ),
          if (directed) ...[
            const SizedBox(height: 4),
            Text(
              'Sent to a specific veterinary officer',
              style: context.text.bodySmall?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static (String, Color) _statusStyle(BuildContext context, String status) {
    final scheme = context.scheme;
    return switch (status) {
      'draft' => ('Not sent', scheme.outline),
      'submitted' || 'received' => ('Awaiting vet', scheme.tertiary),
      'accepted' => ('Accepted', scheme.primary),
      'in_progress' => ('In progress', scheme.primary),
      'completed' => ('Vet completed', scheme.outline),
      'declined' || 'cancelled' => ('Closed', scheme.error),
      _ => (status, scheme.outline),
    };
  }

  static String _serviceLabel(String type) => switch (type) {
        'consultation' => 'Consultation',
        'farm_visit' => 'Farm visit',
        _ => 'Assistance',
      };
}
