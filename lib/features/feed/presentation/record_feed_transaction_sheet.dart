import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../app/widgets/states/progress_button.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/time/kampala_today.dart';
import '../../../data_platform/db/app_database.dart';
import '../data/feed_repository.dart';
import '../domain/feed_models.dart';
import 'feed_providers.dart';

/// Bottom sheet for recording a feed transaction (purchase or consumption).
class RecordFeedTransactionSheet extends ConsumerStatefulWidget {
  const RecordFeedTransactionSheet({required this.feedItem, super.key});

  final FeedItemRow feedItem;

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required FeedItemRow feedItem,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => RecordFeedTransactionSheet(feedItem: feedItem),
    );
  }

  @override
  ConsumerState<RecordFeedTransactionSheet> createState() =>
      _RecordFeedTransactionSheetState();
}

class _RecordFeedTransactionSheetState
    extends ConsumerState<RecordFeedTransactionSheet> {
  final _quantityCtrl = TextEditingController();
  final _unitCostCtrl = TextEditingController();
  var _kind = FeedTransactionKind.purchase;
  String? _selectedBatchId;
  DateTime? _date;

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _unitCostCtrl.dispose();
    super.dispose();
  }

  bool get _isValid {
    final qty = double.tryParse(_quantityCtrl.text.trim()) ?? 0;
    return qty > 0;
  }

  Future<bool> _save() async {
    final farmId = ref.read(primaryFarmProvider).value?.id;
    if (farmId == null) {
      AppSnack.error(context, 'No farm found. Please set up your farm first.');
      return false;
    }

    final qty = double.tryParse(_quantityCtrl.text.trim());
    if (qty == null || qty <= 0) {
      AppSnack.error(context, 'Enter a valid quantity greater than zero.');
      return false;
    }

    final today = ref.read(kampalaTodayProvider);
    final occurredOn = _date ??
        DateTime.utc(today.year, today.month, today.day);

    final input = FeedTransactionInput(
      feedItemId: widget.feedItem.id,
      kind: _kind,
      quantity: qty,
      occurredOn: occurredOn,
      batchId: _kind == FeedTransactionKind.consumption
          ? _selectedBatchId
          : null,
      unitCost: double.tryParse(_unitCostCtrl.text.trim()),
    );

    try {
      await ref.read(feedRepositoryProvider).recordTransaction(
            farmId: farmId,
            input: input,
          );
      return true;
    } catch (error, stack) {
      appLogger.e(
        'Failed to record feed transaction',
        error: error,
        stackTrace: stack,
      );
      if (mounted) {
        AppSnack.error(
          context,
          'Could not save transaction. Please try again.',
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(kampalaTodayProvider);
    final activeBatches = ref.watch(
      StreamProvider<List<BatchRow>>((ref) {
        final farmId = ref.watch(primaryFarmProvider).value?.id;
        if (farmId == null) return Stream.value(<BatchRow>[]);
        return ref
            .watch(batchRepositoryProvider)
            .watchActiveForFarm(farmId);
      }),
    );

    final currentStock = ref.watch(feedStockProvider).value
        ?.firstWhere(
          (s) => s.item.id == widget.feedItem.id,
          orElse: () => FeedStockRow(
            item: widget.feedItem,
            currentQuantity: 0,
            lastTransactionOn: null,
          ),
        );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Record Transaction',
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.feedItem.name,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Current stock chip
            if (currentStock != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: _StockChip(stock: currentStock),
              ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Transaction kind
                    _SectionLabel('Transaction type'),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: FeedTransactionKind.values.map((k) {
                        return ChoiceChip(
                          label: Text(k.label),
                          avatar: Icon(
                            _kindIcon(k),
                            size: 16,
                          ),
                          selected: _kind == k,
                          onSelected: (_) =>
                              setState(() => _kind = k),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Quantity
                    TextField(
                      controller: _quantityCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Quantity *',
                        suffixText: widget.feedItem.unit,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Unit cost (purchase only)
                    if (_kind == FeedTransactionKind.purchase) ...[
                      TextField(
                        controller: _unitCostCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Unit cost (optional)',
                          prefixText: 'UGX ',
                          hintText: 'Cost per unit',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    // Batch selector (consumption only)
                    if (_kind == FeedTransactionKind.consumption) ...[
                      _SectionLabel('Batch (optional)'),
                      const SizedBox(height: AppSpacing.xs),
                      activeBatches.when(
                        data: (batches) => batches.isEmpty
                            ? Text(
                                'No active batches',
                                style: context.text.bodySmall?.copyWith(
                                  color: context.scheme.onSurfaceVariant,
                                ),
                              )
                            : DropdownButtonFormField<String?>(
                                value: _selectedBatchId,
                                decoration: const InputDecoration(
                                  hintText: 'Select batch (optional)',
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    child: Text('None'),
                                  ),
                                  ...batches.map(
                                    (b) => DropdownMenuItem<String?>(
                                      value: b.id,
                                      child: Text(b.name),
                                    ),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _selectedBatchId = v),
                              ),
                        loading: () => const SizedBox(
                          height: 24,
                          child: LinearProgressIndicator(),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    // Date picker
                    _DateRow(
                      today: DateTime.utc(
                        today.year,
                        today.month,
                        today.day,
                      ),
                      selected: _date,
                      onChanged: (d) => setState(() => _date = d),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            // Save button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: ProgressButton(
                label: 'Save transaction',
                busyLabel: 'Saving…',
                onPressed: _isValid ? _save : null,
                onSuccess: () => Navigator.of(context).pop(),
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
}

// ─────────────────────────────────────────────────────────────────────────────

class _StockChip extends StatelessWidget {
  const _StockChip({required this.stock});

  final FeedStockRow stock;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;
    final qty = stock.currentQuantity;
    final label =
        '${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 1)} '
        '${stock.item.unit} in stock';

    final (bg, fg) = stock.isOutOfStock
        ? (scheme.errorContainer, scheme.onErrorContainer)
        : stock.isBelowReorderLevel
            ? (colors.warningContainer, colors.onWarningContainer)
            : (colors.successContainer, colors.onSuccessContainer);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: context.text.labelMedium?.copyWith(color: fg),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.today,
    required this.selected,
    required this.onChanged,
  });

  final DateTime today;
  final DateTime? selected;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final display = selected ?? today;
    final isToday = display.year == today.year &&
        display.month == today.month &&
        display.day == today.day;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel('Date'),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                isToday ? 'Today' : _formatDate(display),
                style: context.text.bodyMedium,
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: display,
              firstDate: DateTime.utc(2020),
              lastDate: today,
            );
            onChanged(picked);
          },
          icon: const Icon(Icons.calendar_today_outlined, size: 16),
          label: const Text('Change'),
        ),
      ],
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.text.labelMedium?.copyWith(
        color: context.scheme.onSurfaceVariant,
      ),
    );
  }
}
