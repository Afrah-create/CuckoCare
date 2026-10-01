import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/tab_empty_state.dart';
import '../../../core/time/kampala_today.dart';
import '../../../data_platform/db/app_database.dart';
import 'batch_display.dart';

final farmBatchesProvider = StreamProvider<List<BatchRow>>((ref) {
  final farmId = ref.watch(primaryFarmProvider).value?.id;
  if (farmId == null) {
    return Stream.value(const []);
  }
  return ref.watch(batchRepositoryProvider).watchActiveForFarm(farmId);
});

class BatchesListScreen extends ConsumerWidget {
  const BatchesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(farmBatchesProvider);
    final today = ref.watch(kampalaTodayProvider);

    return batchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const TabEmptyState(
        icon: Icons.error_outline,
        title: 'Could not load batches',
        message: 'Pull to refresh or try again.',
      ),
      data: (batches) {
        if (batches.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const TabEmptyState(
                icon: Icons.egg_outlined,
                title: 'No batches yet',
                message:
                    'Add your first flock to get a vaccination and care schedule — works offline.',
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () => const BatchNewRoute().push(context),
                icon: const Icon(Icons.add),
                label: const Text('Add batch'),
              ),
            ],
          );
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            ContentFrame.scrollBottomInset(context) + AppSpacing.xl,
          ),
          itemCount: batches.length + 1,
          itemBuilder: (context, index) {
            if (index == batches.length) {
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: FilledButton.icon(
                  onPressed: () => const BatchNewRoute().push(context),
                  icon: const Icon(Icons.add),
                  label: const Text('New batch'),
                ),
              );
            }
            final batch = batches[index];
            return _BatchCard(batch: batch, today: today);
          },
        );
      },
    );
  }
}

class _BatchCard extends ConsumerWidget {
  const _BatchCard({required this.batch, required this.today});

  final BatchRow batch;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final age = batchAgeLabel(batch, today);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            batch.birdType == 'broiler'
                ? Icons.restaurant
                : Icons.egg_alt_outlined,
          ),
        ),
        title: Text(batch.name),
        subtitle: Text(
          '${birdTypeLabel(batch.birdType)} · $age · ${batch.initialCount} birds',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => BatchDetailRoute(batchId: batch.id).push(context),
      ),
    );
  }
}
