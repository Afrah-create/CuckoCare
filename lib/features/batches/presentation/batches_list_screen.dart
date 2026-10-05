import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/empty_state.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/pending_sync_badge.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../core/error/failure_mapper.dart';
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

    return AsyncStateView<List<BatchRow>>(
      screenId: 'batches',
      value: batchesAsync,
      onRetry: () => ref.invalidate(farmBatchesProvider),
      skeleton: const ListSkeleton(),
      isEmpty: (batches) => batches.isEmpty,
      empty: EmptyState(
        title: 'No batches yet',
        message: 'Add your first flock to get a care schedule. This works offline.',
        actionLabel: 'Add batch',
        onAction: () => const BatchNewRoute().push(context),
        showMark: true,
      ),
      error: (error, _) => ErrorState(
        failure: FailureMapper.mapObject(error),
        onRetry: () => ref.invalidate(farmBatchesProvider),
      ),
      builder: (batches) {
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PendingSyncBadge(rowId: batch.id),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => BatchDetailRoute(batchId: batch.id).push(context),
      ),
    );
  }
}
