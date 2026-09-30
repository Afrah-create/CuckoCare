import 'package:flutter/material.dart';

import '../../../app/router/routes/typed_routes.dart';

class BatchDetailScreen extends StatelessWidget {
  const BatchDetailScreen({required this.batchId, super.key});

  final String batchId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Batch $batchId')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Batch detail',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Vaccination task (QA)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => BatchVaccinationTaskRoute(
              batchId: batchId,
              taskId: '9',
            ).push(context),
          ),
        ],
      ),
    );
  }
}
