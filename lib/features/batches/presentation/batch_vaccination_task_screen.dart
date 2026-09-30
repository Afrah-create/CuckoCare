import 'package:flutter/material.dart';

class BatchVaccinationTaskScreen extends StatelessWidget {
  const BatchVaccinationTaskScreen({
    required this.batchId,
    required this.taskId,
    super.key,
  });

  final String batchId;
  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vaccination task')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Batch $batchId · task $taskId'),
      ),
    );
  }
}
