import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/error/result.dart';
import '../data/vet_map_repository.dart';
import 'vet_inbox_providers.dart';

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
    if (pins.length == 1) {
      _mapController.move(
        LatLng(pins.first.latitude!, pins.first.longitude!),
        13,
      );
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

    return mapAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Could not load map: $e', textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(vetMapProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (items) {
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
                            pin.priority == 'urgent'
                                ? Icons.local_hospital
                                : Icons.location_on,
                            color: pin.priority == 'urgent'
                                ? context.scheme.error
                                : context.scheme.primary,
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
                              ? '${items.length} open requests · no shared GPS yet'
                              : '${pins.length} on map · ${items.length} open requests',
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
            if (pins.isEmpty && items.isNotEmpty)
              Positioned(
                bottom: AppSpacing.lg,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request accepted')),
        );
      case Error(failure: final f):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
    }
  }
}

class _RequestDetailSheet extends StatelessWidget {
  const _RequestDetailSheet({
    required this.request,
    required this.onClose,
    required this.onAccept,
  });

  final VetMapRequest request;
  final VoidCallback onClose;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Material(
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${request.photoObjectKeys.length} photo(s) attached',
                  style: context.text.labelMedium?.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              if (request.status == 'submitted' ||
                  request.status == 'received')
                FilledButton(
                  onPressed: onAccept,
                  child: const Text('Accept request'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
