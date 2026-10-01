import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

class InlineBanner extends StatelessWidget {
  const InlineBanner({
    required this.message,
    required this.icon,
    this.onDismiss,
    super.key,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Semantics(
      liveRegion: true,
      child: Material(
        color: scheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: scheme.error),
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
