import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../data_platform/db/app_database.dart';
import '../domain/farm_gps.dart';
import '../domain/farm_profile.dart';
import 'farm_gps_controller.dart';
import 'farm_gps_permission_dialog.dart';

class FarmGpsCaptureCard extends ConsumerWidget {
  const FarmGpsCaptureCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farm = ref.watch(primaryFarmProvider).value;
    final capture = ref.watch(farmGpsCaptureControllerProvider);

    if (farm == null) {
      return const SizedBox.shrink();
    }

    final reading = gpsReadingFromFarm(farm);
    final hasGps = reading != null;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GpsHeroHeader(hasGps: hasGps),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  hasGps ? 'Farm GPS saved' : 'Pin your farm on the map',
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  hasGps
                      ? 'Vets can find you faster when you request assistance.'
                      : 'We only use your location while you capture it — to help veterinarians reach your farm.',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                if (reading != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _GpsSavedDetails(farm: farm, reading: reading),
                ],
                if (capture.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _InlineError(message: capture.errorMessage!),
                ],
                const SizedBox(height: AppSpacing.md),
                _ActionRow(
                  farmId: farm.id,
                  hasGps: hasGps,
                  isCapturing: capture.isCapturing,
                  lastFailureMessage: capture.errorMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsHeroHeader extends StatelessWidget {
  const _GpsHeroHeader({required this.hasGps});

  final bool hasGps;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = hasGps ? Icons.check_circle_rounded : Icons.location_on_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.85),
            scheme.secondaryContainer.withValues(alpha: 0.45),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.92),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: scheme.primary, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              hasGps ? 'Location ready for vet visits' : 'GPS for veterinary support',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsSavedDetails extends StatelessWidget {
  const _GpsSavedDetails({required this.farm, required this.reading});

  final FarmRow farm;
  final FarmGpsReading reading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final captured = DateFormat.yMMMd().add_jm().format(
          reading.capturedAt.toLocal(),
        );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            icon: Icons.my_location_outlined,
            label: 'Coordinates',
            value: formatFarmCoordinates(reading),
          ),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(
            icon: Icons.gps_fixed,
            label: 'Accuracy',
            value: formatGpsAccuracy(reading.accuracyMeters),
          ),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(
            icon: Icons.schedule,
            label: 'Captured',
            value: captured,
          ),
          if (farm.village != null && farm.village!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
              icon: Icons.place_outlined,
              label: 'Address on file',
              value: '${farm.district ?? ''}, ${farm.village}',
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: scheme.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends ConsumerWidget {
  const _ActionRow({
    required this.farmId,
    required this.hasGps,
    required this.isCapturing,
    this.lastFailureMessage,
  });

  final String farmId;
  final bool hasGps;
  final bool isCapturing;
  final String? lastFailureMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(farmGpsCaptureControllerProvider.notifier);
    final showSettings = lastFailureMessage != null &&
        (lastFailureMessage!.contains('Settings') ||
            lastFailureMessage!.contains('blocked') ||
            lastFailureMessage!.contains('location services'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: isCapturing
              ? null
              : () async {
                  final allowed = await confirmFarmGpsPermission(context);
                  if (!allowed || !context.mounted) {
                    return;
                  }
                  final ok = await controller.captureForFarm(farmId);
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Farm location saved'),
                      ),
                    );
                  }
                },
          icon: isCapturing
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : Icon(hasGps ? Icons.refresh : Icons.location_searching),
          label: Text(
            isCapturing
                ? 'Getting GPS fix…'
                : hasGps
                    ? 'Update location'
                    : 'Allow & capture location',
          ),
        ),
        if (showSettings) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: isCapturing
                ? null
                : () async {
                    if (lastFailureMessage!.contains('location services') ||
                        lastFailureMessage!.contains('Turn on location')) {
                      await controller.openLocationSettings();
                    } else {
                      await controller.openSettingsForPermission();
                    }
                  },
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Open settings'),
          ),
        ],
      ],
    );
  }
}
