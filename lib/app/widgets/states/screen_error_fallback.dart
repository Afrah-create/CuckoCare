import 'package:flutter/material.dart';

import '../../router/navigator_keys.dart';
import '../../router/routes/typed_routes.dart';
import '../../theme/app_spacing.dart';
import '../../theme/theme_context.dart';

class ScreenErrorFallback extends StatelessWidget {
  const ScreenErrorFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.scheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sentiment_dissatisfied_outlined, color: context.scheme.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Something went wrong on this screen',
                style: context.text.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your farm data is still saved on this phone.',
                style: context.text.bodyMedium?.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () {
                  final nav = rootNavigatorKey.currentContext;
                  if (nav != null) {
                    const TodayRoute().go(nav);
                  }
                },
                child: const Text('Go to Today'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
