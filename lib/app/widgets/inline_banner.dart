import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

enum BannerTone { error, warning, info }

class InlineBanner extends StatelessWidget {
  const InlineBanner({
    required this.message,
    required this.icon,
    this.onDismiss,
    this.tone = BannerTone.error,
    super.key,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onDismiss;
  final BannerTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;
    final (background, foreground) = switch (tone) {
      BannerTone.error => (
          scheme.errorContainer.withValues(alpha: 0.35),
          scheme.error,
        ),
      BannerTone.warning => (
          colors.warningContainer.withValues(alpha: 0.45),
          colors.onWarningContainer,
        ),
      BannerTone.info => (
          colors.infoContainer.withValues(alpha: 0.4),
          colors.onInfoContainer,
        ),
    };

    return Semantics(
      liveRegion: true,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: foreground),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: context.text.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onDismiss,
                  icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
