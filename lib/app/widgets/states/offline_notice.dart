import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/theme_context.dart';

class OfflineNotice extends StatelessWidget {
  const OfflineNotice({
    this.message = 'You are offline. Saved data is still here.',
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.offlineSurface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 18,
              color: context.colors.onWarningContainer,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onWarningContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StaleDataCaption extends StatelessWidget {
  const StaleDataCaption({required this.updatedLabel, super.key});

  final String updatedLabel;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Showing saved data. Updated $updatedLabel',
      style: context.text.bodySmall?.copyWith(
        color: context.scheme.onSurfaceVariant,
      ),
    );
  }
}
