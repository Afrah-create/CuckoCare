import 'package:flutter/material.dart';

import '../../../app/router/routes/typed_routes.dart';
import '../../../app/widgets/tab_empty_state.dart';

class BatchesListScreen extends StatelessWidget {
  const BatchesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const TabEmptyState(
          icon: Icons.egg_outlined,
          title: 'No batches yet',
          message:
              'When you add flocks, they will show up here with age and counts.',
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.egg),
            title: const Text('Sample batch (QA)'),
            subtitle: const Text('Tap to test back navigation'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => const BatchDetailRoute(batchId: '1').push(context),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => const BatchNewRoute().push(context),
          icon: const Icon(Icons.add),
          label: const Text('Add batch'),
        ),
      ],
    );
  }
}
