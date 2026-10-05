import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import 'states/app_busy_indicator.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.showCheck = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        child: AnimatedSwitcher(
          duration: AppMotion.fast,
          child: loading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  height: 22,
                  width: 22,
                  child: AppBusyIndicator(
                    size: 22,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : showCheck
                  ? Row(
                      key: const ValueKey('done'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, size: 18),
                        const SizedBox(width: AppSpacing.xs),
                        Text(label),
                      ],
                    )
                  : Text(label, key: const ValueKey('label')),
        ),
      ),
    );
  }
}
