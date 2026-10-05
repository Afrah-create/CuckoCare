import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../app/widgets/states/skeleton.dart';
import 'vet_incident_photo_providers.dart';
import 'vet_incident_photo_viewer.dart';

class VetIncidentPhotoGallery extends ConsumerWidget {
  const VetIncidentPhotoGallery({
    required this.photoObjectKeys,
    super.key,
  });

  final List<String> photoObjectKeys;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (photoObjectKeys.isEmpty) {
      return const SizedBox.shrink();
    }

    final urlsAsync = ref.watch(vetIncidentPhotoUrlsProvider(photoObjectKeys));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library_outlined, color: context.scheme.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Incident photos',
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        urlsAsync.when(
          loading: () => const PhotoStripSkeleton(),
          error: (_, __) => Text(
            'Could not load photos. Pull to refresh or try again later.',
            style: context.text.bodySmall?.copyWith(
              color: context.scheme.error,
            ),
          ),
          data: (urls) {
            if (urls.isEmpty) {
              return Text(
                'Photos not available yet. They may still be uploading.',
                style: context.text.bodySmall?.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
              );
            }
            return SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: urls.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  return _PhotoThumb(
                    url: urls[index],
                    onTap: () => openVetIncidentPhotoViewer(
                      context,
                      urls: urls,
                      initialIndex: index,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.url, required this.onTap});

  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              url,
              width: 112,
              height: 112,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) {
                  return child;
                }
                return const SkeletonBlock(
                  width: 112,
                  height: 112,
                  radius: 14,
                );
              },
              errorBuilder: (_, __, ___) => SizedBox(
                width: 112,
                height: 112,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: context.scheme.onSurfaceVariant,
                ),
              ),
            ),
            Positioned(
              right: 6,
              bottom: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.scheme.scrim.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.zoom_in,
                    color: context.scheme.surface,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
