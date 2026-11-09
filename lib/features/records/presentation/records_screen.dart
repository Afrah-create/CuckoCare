import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/di/providers.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../messaging/presentation/messaging_providers.dart';
import '../../messaging/presentation/unread_badge.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/empty_state.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/pending_sync_badge.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../data_platform/db/app_database.dart';
import '../../health/data/health_repository.dart';
import '../domain/farmer_incident_filters.dart';
import 'farmer_incident_filter_bar.dart';
import 'mortality_records_view.dart';

final farmerIncidentsProvider = StreamProvider<List<FarmerIncidentEntry>>((
  ref,
) {
  final farmId = ref.watch(primaryFarmProvider).value?.id;
  if (farmId == null) {
    return Stream.value(const []);
  }
  return ref.watch(healthRepositoryProvider).watchFarmIncidents(farmId);
});

enum RecordsSection { health, mortality }

class RecordsSectionNotifier extends Notifier<RecordsSection> {
  @override
  RecordsSection build() => RecordsSection.health;

  void select(RecordsSection section) => state = section;
}

final recordsSectionProvider =
    NotifierProvider<RecordsSectionNotifier, RecordsSection>(
      RecordsSectionNotifier.new,
    );

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(recordsSectionProvider);

    return AppPage(
      primary: false,
      frame: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ContentFrame(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: SegmentedButton<RecordsSection>(
                segments: const [
                  ButtonSegment(
                    value: RecordsSection.health,
                    icon: Icon(Icons.medical_services_outlined),
                    label: Text('Health'),
                  ),
                  ButtonSegment(
                    value: RecordsSection.mortality,
                    icon: Icon(Icons.trending_down),
                    label: Text('Mortality'),
                  ),
                ],
                selected: {section},
                showSelectedIcon: false,
                onSelectionChanged: (s) =>
                    ref.read(recordsSectionProvider.notifier).select(s.first),
              ),
            ),
          ),
          Expanded(
            child: switch (section) {
              RecordsSection.health => const _HealthRecordsView(),
              RecordsSection.mortality => const MortalityRecordsView(),
            },
          ),
        ],
      ),
    );
  }
}

class _HealthRecordsView extends ConsumerStatefulWidget {
  const _HealthRecordsView();

  @override
  ConsumerState<_HealthRecordsView> createState() => _HealthRecordsViewState();
}

class _HealthRecordsViewState extends ConsumerState<_HealthRecordsView> {
  FarmerIncidentFilters _filters = const FarmerIncidentFilters();

  List<String> _symptomsOf(FarmerIncidentEntry entry) {
    return (jsonDecode(entry.record.symptomsJson) as List)
        .map((e) => e.toString())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<FarmerIncidentEntry> _apply(List<FarmerIncidentEntry> entries) {
    final filtered = entries
        .where(
          (entry) => _filters.matches(
            requestStatus: entry.vetRequest?.status,
            symptoms: _symptomsOf(entry),
          ),
        )
        .toList();
    filtered.sort(
      (a, b) => _filters.compare(
        aOccurredOn: a.record.occurredOn,
        bOccurredOn: b.record.occurredOn,
        aAffected: a.record.affectedBirdCount,
        bAffected: b.record.affectedBirdCount,
      ),
    );
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final incidentsAsync = ref.watch(farmerIncidentsProvider);

    return AsyncStateView<List<FarmerIncidentEntry>>(
      value: incidentsAsync,
      onRetry: () => ref.invalidate(farmerIncidentsProvider),
      skeleton: const ListSkeleton(),
      isEmpty: (entries) => entries.isEmpty,
      empty: const EmptyState(
        icon: Icons.note_alt_outlined,
        title: 'No health records yet',
        message:
            'Incidents and vet requests will show up here after you add one.',
      ),
      error: (error, _) => ErrorState(
        failure: FailureMapper.mapObject(error),
        onRetry: () => ref.invalidate(farmerIncidentsProvider),
      ),
      builder: (entries) {
        final visible = _apply(entries);
        final symptoms = FarmerIncidentFilters.symptomsPresent(
          entries.map(_symptomsOf),
        );
        return ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health incidents',
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      visible.length == entries.length
                          ? '${entries.length} saved on this farm'
                          : '${visible.length} of ${entries.length} shown',
                      style: context.text.bodySmall?.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FarmerIncidentFilterBar(
                      value: _filters,
                      symptoms: symptoms,
                      onChanged: (next) => setState(() => _filters = next),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: visible.isEmpty
                    ? EmptyState(
                        kind: EmptyKind.filtered,
                        icon: Icons.filter_alt_off_outlined,
                        title: 'No incidents match',
                        message:
                            'Clear a filter or change the sort to see more.',
                        actionLabel: 'Clear filters',
                        onAction: () => setState(
                          () => _filters = const FarmerIncidentFilters(),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.only(
                          bottom: ContentFrame.scrollBottomInset(context),
                        ),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) =>
                            _IncidentRecordCard(entry: visible[index]),
                      ),
              ),
            ],
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.summary,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PendingSyncBadge(rowId: record.id),
              ],
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
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
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
                        AppSnack.success(
                          context,
                          'Request saved. It will be sent when you are online.',
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        AppSnack.error(
                          context,
                          "Couldn't notify the vet. Please try again.",
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
  const _DraftVetRequestRow({required this.requestId, required this.onPublish});

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

class _VetRequestStatusRow extends ConsumerWidget {
  const _VetRequestStatusRow({required this.request});

  final VetAssistanceRequestRow request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () => CaseMessagesRoute(
                requestId: request.id,
                farmId: request.farmId,
                status: request.status,
                priority: request.priority,
                summary: request.farmerNotes,
              ).push(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UnreadBadge(
                    count:
                        ref.watch(caseUnreadProvider(request.id)).value ?? 0,
                  ),
                  const SizedBox(width: 6),
                  Text(_chatActionLabel(status)),
                ],
              ),
            ),
          ),
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

  static String _chatActionLabel(String status) => switch (status) {
    'accepted' || 'in_progress' => 'Message vet',
    'completed' || 'declined' || 'cancelled' => 'View messages',
    _ => 'View messages',
  };
}
