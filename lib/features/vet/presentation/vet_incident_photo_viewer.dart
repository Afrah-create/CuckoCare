import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/widgets/states/skeleton.dart';

void openVetIncidentPhotoViewer(
  BuildContext context, {
  required List<String> urls,
  required int initialIndex,
}) {
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close photo viewer',
    pageBuilder: (dialogContext, _, __) {
      return VetIncidentPhotoViewer(
        urls: urls,
        initialIndex: initialIndex,
      );
    },
  );
}

class VetIncidentPhotoViewer extends StatefulWidget {
  const VetIncidentPhotoViewer({
    required this.urls,
    required this.initialIndex,
    super.key,
  });

  final List<String> urls;
  final int initialIndex;

  @override
  State<VetIncidentPhotoViewer> createState() => _VetIncidentPhotoViewerState();
}

class _VetIncidentPhotoViewerState extends State<VetIncidentPhotoViewer> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.urls.length - 1);
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Material(
        color: scheme.surface,
        child: Column(
          children: [
            AppBar(
              title: Text('Photo ${_index + 1} of ${widget.urls.length}'),
              leading: CloseButton(onPressed: () => context.pop()),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.urls.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Image.network(
                          widget.urls[index],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              return child;
                            }
                            return const SkeletonScope(
                              child: SkeletonBlock(
                                width: 220,
                                height: 160,
                                radius: 12,
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (widget.urls.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < widget.urls.length; i++)
                      Container(
                        width: i == _index ? 10 : 8,
                        height: i == _index ? 10 : 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _index
                              ? scheme.primary
                              : scheme.outlineVariant,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
