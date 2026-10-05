import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/empty_state.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../core/error/result.dart';
import '../data/vet_map_repository.dart';
import '../domain/vet_incident_detail.dart';
import 'vet_incident_detail_screen.dart';
import 'vet_incident_photo_gallery.dart';
import '../domain/vet_case_workflow.dart';
import 'vet_inbox_providers.dart';
import 'vet_map_pin_style.dart';

/// Kampala — default map center when no pins exist.
const _defaultCenter = LatLng(0.3476, 32.5825);

class VetMapScreen extends ConsumerStatefulWidget {
  const VetMapScreen({super.key});

  @override
  ConsumerState<VetMapScreen> createState() => _VetMapScreenState();
}

class _VetMapScreenState extends ConsumerState<VetMapScreen> {
  final MapController _mapController = MapController();
  VetMapRequest? _selected;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitToPins(List<VetMapRequest> items) {
    final pins = items.where((r) => r.hasMapPin).toList();
    if (pins.isEmpty) {
      return;
    }
    final first = LatLng(pins.first.latitude!, pins.first.longitude!);
    if (pins.length == 1 ||
        pins.every(
          (p) => p.latitude == pins.first.latitude && p.longitude == pins.first.longitude,
        )) {
      _mapController.move(first, 13);
      return;
    }
    final bounds = LatLngBounds.fromPoints(
      pins.map((p) => LatLng(p.latitude!, p.longitude!)).toList(),
    );
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapAsync = ref.watch(vetMapProvider);

    return AsyncStateView(
      screenId: 'vet-map',
      value: mapAsync,
      onRetry: () => ref.invalidate(vetMapProvider),
      skeleton: const MapSkeleton(),
      isEmpty: (items) => items.isEmpty,
      empty: const EmptyState(
        icon: Icons.map_outlined,
        title: 'No farms on the map',
        message: 'Requests with a saved location will appear here.',
      ),
      error: (error, _) => ErrorState(
        failure: FailureMapper.mapObject(error),
        onRetry: () => ref.invalidate(vetMapProvider),
      ),
      builder: (items) {
        final pins = items.where((r) => r.hasMapPin).toList();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && pins.isNotEmpty) {
            _fitToPins(items);
          }
        });

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: pins.isNotEmpty
                    ? LatLng(pins.first.latitude!, pins.first.longitude!)
                    : _defaultCenter,
                initialZoom: pins.isEmpty ? 11 : 12,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.cucocare.cucocare',
                ),
                MarkerLayer(
                  markers: [
                    for (final pin in pins)
                      Marker(
                        point: LatLng(pin.latitude!, pin.longitude!),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = pin),
                          child: Icon(
                            vetMapPinIcon(pin.status),
                            color: vetMapPinColor(
                              status: pin.status,
                              priority: pin.priority,
                              scheme: context.scheme,
                            ),
                            size: 40,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(12),
                color: context.scheme.surface.withValues(alpha: 0.94),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.map_outlined, color: context.scheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          pins.isEmpty
                              ? '${items.length} requests · no shared GPS yet'
                              : '${pins.length} on map · ${items.length} requests',
                          style: context.text.bodyMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: () => ref.invalidate(vetMapProvider),
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_selected == null)
              Positioned(
                bottom: AppSpacing.lg,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: _MapLegend(scheme: context.scheme),
              ),
            if (_selected != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _RequestDetailSheet(
                  request: _selected!,
                  onClose: () => setState(() => _selected = null),
                  onAccept: () => _accept(_selected!.id),
                ),
              ),
            if (_selected == null && pins.isEmpty && items.isNotEmpty)
              Positioned(
                bottom: 72,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'Some farmers have not shared farm GPS. '
                      'Check the Requests tab for full details.',
                      style: context.text.bodyMedium,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _accept(String requestId) async {
    final result = await ref.read(vetInboxRepositoryProvider).setRequestStatus(
          requestId: requestId,
          status: 'accepted',
        );
    if (!mounted) {
      return;
    }
    switch (result) {
      case Success():
        ref.invalidate(vetMapProvider);
        ref.invalidate(vetInboxProvider);
        setState(() => _selected = null);
        AppSnack.success(context, 'Request accepted');
      case Error(failure: final f):
        AppSnack.error(context, f.message);
    }
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    const statuses = [
      'submitted',
      'accepted',
      'in_progress',
      'completed',
    ];
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      color: scheme.surface.withValues(alpha: 0.94),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: 4,
          children: [
            for (final status in statuses)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    vetMapPinIcon(status),
                    size: 16,
                    color: vetMapPinColor(
                      status: status,
                      priority: 'normal',
                      scheme: scheme,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    vetMapLegendLine(status),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RequestDetailSheet extends ConsumerWidget {
  const _RequestDetailSheet({
    required this.request,
    required this.onClose,
    required this.onAccept,
  });

  final VetMapRequest request;
  final VoidCallback onClose;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.scheme;
    return Material(
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.55,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.summary,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                request.locationLabel,
                style: context.text.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                vetRequestStatusLabel(request.status),
                style: context.text.labelLarge?.copyWith(
                  color: vetMapPinColor(
                    status: request.status,
                    priority: request.priority,
                    scheme: scheme,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (request.affectedBirdCount != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text('Birds affected: ${request.affectedBirdCount}'),
              ],
              if (request.symptoms.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final s in request.symptoms)
                      Chip(
                        label: Text(s),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
              if (request.farmerNotes != null &&
                  request.farmerNotes!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(request.farmerNotes!.trim()),
              ],
              if (request.photoObjectKeys.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                VetIncidentPhotoGallery(
                  photoObjectKeys: request.photoObjectKeys,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () {
                  onClose();
                  openVetIncidentDetail(
                    context,
                    VetIncidentDetail.fromMap(request),
                  );
                },
                child: const Text('Full incident details'),
              ),
              if (request.status == 'submitted' ||
                  request.status == 'received') ...[
                const SizedBox(height: AppSpacing.sm),
                FilledButton(
                  onPressed: onAccept,
                  child: const Text('Accept request'),
                ),
              ] else if (request.status == 'completed') ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This visit is complete. Pin is shown for your records.',
                  style: context.text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
            ),
          ),
        ),
      ),
    );
  }
}
