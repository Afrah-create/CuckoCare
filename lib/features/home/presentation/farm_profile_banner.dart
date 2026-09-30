import 'package:flutter/material.dart';
import '../../../app/router/routes/typed_routes.dart';

class FarmProfileBanner extends StatelessWidget {
  const FarmProfileBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.primaryContainer.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Complete your farm profile (name, location, phone) to enable full sync.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () => const MoreFarmRoute().push(context),
              child: const Text('Complete'),
            ),
          ],
        ),
      ),
    );
  }
}
