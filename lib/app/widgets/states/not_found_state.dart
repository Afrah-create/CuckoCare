import 'package:flutter/material.dart';

import '../../layout/content_frame.dart';
import '../../theme/app_spacing.dart';
import '../../theme/theme_context.dart';

class NotFoundState extends StatelessWidget {
  const NotFoundState({
    required this.onBack,
    this.title = 'This item was removed',
    this.message = 'It is no longer on this phone.',
    this.actionLabel = 'Go back',
    super.key,
  });

  final VoidCallback onBack;
  final String title;
  final String message;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return ContentFrame(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 40,
              color: context.scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: context.text.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: context.text.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: onBack, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
