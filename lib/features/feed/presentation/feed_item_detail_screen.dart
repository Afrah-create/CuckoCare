import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/empty_state.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../data_platform/db/app_database.dart';
import '../domain/feed_models.dart';
import 'feed_item_form_sheet.dart';
import 'feed_providers.dart';
import 'record_feed_transaction_sheet.dart';

/// Per-item transaction history with stock summary and actions.
class FeedItemDetailScreen extends ConsumerWidget {
  const FeedItemDetailScreen({required this.feedItemId, super.key});

  final String feedItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(
      StreamProvider<List<FeedTransactionRow>>(
        (ref) => ref
            .watch(feedRepositoryProvider)
            .watchTransactions(feedItemId),
      ),
    );
    final stockAsync = ref.watch(feedStockProvider);

    final stock = stockAsync.value?.firstWhereOrNull(
      (s) => s.feedItem.id == feedItemId,
    );

    return AppPage(
      title: stock?.feedItem.name ?? 'Feed item',
      actions: [
        if (stock != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () =>
                FeedItemFormSheet.show(context, ref, existing: stock.feedItem),
          ),
        if (stock != null)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, ref, stock.feedItem),
          ),
      ],
      floatingActionButton: stock != null
          ? FloatingActionButton.extended(
              heroTag: 'feed_detail_fab',
              onPressed: () => RecordFeedTransactionSheet.show(
                context,
                ref,
                feedItem: stock.feedItem,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Record'),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (stock != null) _StockSummaryCard(stock: stock),
          Expanded(
            child: AsyncStateView(
              value: txAsync,
              skeleton: const ListSkeleton(),
              onRetry: () => ref.invalidate(feedTransactionsProvider),
              builder: (transactions) {
                if (transactions.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions yet',
                    message: 'Record a purchase or consumption to see history.',
                    actionLabel: 'Record transaction',
                    onAction: stock == null
                        ? null
                        : () => RecordFeedTransactionSheet.show(
                              context,
                              ref,
                              feedItem: stock.feedItem,
                            ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    top: AppSpacing.sm,
                    bottom: AppSpacing.xl + 72,
                  ),
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, i) => _TransactionTile(
                    tx: transactions[i],
                    unit: stock?.feedItem.unit ?? '',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    FeedItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete feed item?'),
        content: Text(
          'This will hide "${item.name}" from the list. '
          'Transaction history is preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(feedRepositoryProvider).deleteFeedItem(item);
      if (context.mounted) {
        AppSnack.success(context, '${item.name} removed');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        AppSnack.error(context, 'Could not delete. Please try again.');
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StockSummaryCard extends StatelessWidget {
  const _StockSummaryCard({required this.stock});

  final FeedMetrics stock;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;
    final qty = stock.currentQuantity;
    final label =
        '${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 1)} '
        '${stock.feedItem.unit}';

    final statusColor = stock.isOutOfStock
        ? scheme.error
        : stock.isBelowReorderLevel
            ? colors.warning
            : colors.success;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current stock',
                  style: context.text.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  label,
                  style: context.text.headlineSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (stock.isBelowReorderLevel)
                  Text(
                    stock.isOutOfStock ? 'Out of stock' : 'Below reorder level',
                    style: context.text.labelSmall?.copyWith(
                      color: statusColor,
                    ),
                  ),
                if (stock.isInconsistent)
                  Text(
                    'Please review — ledger inconsistency detected',
                    style: context.text.labelSmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
              ],
            ),
          ),
          if (stock.feedItem.reorderLevel != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Reorder at',
                  style: context.text.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${_fmt(stock.feedItem.reorderLevel!)} ${stock.feedItem.unit}',
                  style: context.text.labelMedium,
                ),
              ],
            ),
        ],
      ),
    );
  }

  static String _fmt(double v) =>
      v.truncateToDouble() == v ? v.toInt().toString() : v.toString();
}

// ─────────────────────────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx, required this.unit});

  final FeedTransactionRow tx;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final kind = FeedTransactionKind.fromStorage(tx.kind);
    final isPositive = kind.stockSign > 0;
    final colors = context.colors;
    final scheme = context.scheme;

    final qtyColor = isPositive ? colors.success : scheme.error;
    final sign = isPositive ? '+' : '−';
    final qty = tx.quantity;
    final qtyLabel =
        '$sign${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 1)} $unit';

    return Card(
      elevation: AppSpacing.elevationCard,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isPositive
                    ? colors.successContainer
                    : scheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _kindIcon(kind),
                size: 18,
                color: isPositive
                    ? colors.onSuccessContainer
                    : scheme.onErrorContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kind.label,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatDate(tx.occurredOn),
                    style: context.text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              qtyLabel,
              style: context.text.titleMedium?.copyWith(
                color: qtyColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _kindIcon(FeedTransactionKind k) => switch (k) {
        FeedTransactionKind.purchase => Icons.add_shopping_cart_outlined,
        FeedTransactionKind.consumption => Icons.restaurant_outlined,
        FeedTransactionKind.adjustment => Icons.tune_outlined,
        FeedTransactionKind.wastage => Icons.delete_outline,
      };

  static String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

extension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
