import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/empty_state.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../core/error/failure_mapper.dart';
import '../../batches/data/batch_views.dart';
import '../../batches/presentation/batch_actions.dart';
import '../../batches/presentation/batch_labels.dart';
import '../../batches/presentation/batch_providers.dart';
import '../../batches/presentation/batch_widgets.dart';
import '../../batches/presentation/loss_detail_sheet.dart';

class _MortalityBatchFilter extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? batchId) => state = batchId;
}

final _mortalityBatchFilterProvider =
    NotifierProvider<_MortalityBatchFilter, String?>(_MortalityBatchFilter.new);

/// Losses across every batch on the farm, newest first.
class MortalityRecordsView extends ConsumerWidget {
  const MortalityRecordsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchFilter = ref.watch(_mortalityBatchFilterProvider);
    final lossesAsync = ref.watch(farmLossesProvider(batchFilter));
    final batches = ref.watch(allBatchSummariesProvider).value ?? const [];
    final highlighted = ref.watch(highlightedLossProvider);
    final permissions = ref.watch(batchPermissionsProvider);
    final closedIds = {
      for (final b in batches)
        if (b.facts.isClosed) b.batch.id,
    };
    final recordable = [
      for (final b in batches)
        if (!b.facts.isClosed && b.metrics.liveCount > 0) b,
    ];

    return ContentFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: batches.any((b) => b.batch.id == batchFilter)
                      ? batchFilter
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Batch'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All batches'),
                    ),
                    for (final b in batches)
                      DropdownMenuItem(
                        value: b.batch.id,
                        child: Text(
                          b.batch.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: ref
                      .read(_mortalityBatchFilterProvider.notifier)
                      .select,
                ),
              ),
              if (permissions.canRecordLosses && recordable.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, AppSpacing.fieldHeight),
                  ),
                  onPressed: () =>
                      _pickBatchAndRecord(context, ref, recordable),
                  icon: const Icon(Icons.add),
                  label: const Text('Record loss'),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: AsyncStateView<List<FarmLossRow>>(
              value: lossesAsync,
              skeleton: const ListSkeleton(),
              onRetry: () => ref.invalidate(farmLossesProvider(batchFilter)),
              isEmpty: (rows) => rows.isEmpty,
              empty: const EmptyState(
                icon: Icons.favorite_outline,
                title: 'No losses recorded',
                message: "That's good news.",
              ),
              error: (error, _) => ErrorState(
                failure: FailureMapper.mapObject(error),
                onRetry: () => ref.invalidate(farmLossesProvider(batchFilter)),
              ),
              builder: (rows) => ListView.builder(
                padding: EdgeInsets.only(
                  top: AppSpacing.xs,
                  bottom: ContentFrame.scrollBottomInset(context),
                ),
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final row = rows[index];
                  final entry = lossEntryFromRow(row.loss);
                  return LossTile(
                    entry: entry,
                    batchName: row.batchName,
                    highlight: entry.id == highlighted,
                    onTap: () => showLossDetailSheet(
                      context,
                      ref,
                      entry: entry,
                      batchName: row.batchName,
                      readOnly: closedIds.contains(entry.batchId),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickBatchAndRecord(
    BuildContext context,
    WidgetRef ref,
    List<BatchSummary> batches,
  ) async {
    final batchId = batches.length == 1
        ? batches.single.batch.id
        : await showModalBottomSheet<String>(
            context: context,
            showDragHandle: true,
            useSafeArea: true,
            isScrollControlled: true,
            builder: (sheetContext) => SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      'Which batch?',
                      style: sheetContext.text.titleLarge,
                    ),
                  ),
                  for (final b in batches)
                    ListTile(
                      title: Text(b.batch.name),
                      subtitle: Text(
                        '${formatCount(b.metrics.liveCount)} live birds',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => sheetContext.pop(b.batch.id),
                    ),
                ],
              ),
            ),
          );
    if (batchId == null || !context.mounted) {
      return;
    }
    await openRecordLoss(context, ref, batchId);
  }
}
