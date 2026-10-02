import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../farms/presentation/farm_gps_permission_dialog.dart';
import 'vet_gps_controller.dart';

class VetGpsCaptureCard extends ConsumerWidget {
  const VetGpsCaptureCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vetGpsCaptureControllerProvider);
    final scheme = context.scheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.my_location, color: scheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Your location',
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Share GPS when accepting farm visits so CucoCare can show distance and routes on the map.',
              style: context.text.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                state.errorMessage!,
                style: context.text.bodySmall?.copyWith(color: scheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonalIcon(
              onPressed: state.isCapturing
                  ? null
                  : () async {
                      final ok = await confirmFarmGpsPermission(context);
                      if (!ok || !context.mounted) {
                        return;
                      }
                      final saved = await ref
                          .read(vetGpsCaptureControllerProvider.notifier)
                          .captureAndUpload();
                      if (saved && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location updated')),
                        );
                      }
                    },
              icon: state.isCapturing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.gps_fixed),
              label: Text(state.isCapturing ? 'Capturing…' : 'Update my location'),
            ),
          ],
        ),
      ),
    );
  }
}
