import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

class PasswordRequirementChip extends StatelessWidget {
  const PasswordRequirementChip({required this.met, super.key});

  final bool met;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: met
            ? colors.successContainer.withValues(alpha: 0.5)
            : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 16,
            color: met ? colors.onSuccessContainer : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '8+ characters',
            style: context.text.labelSmall?.copyWith(
              color: met ? colors.onSuccessContainer : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
