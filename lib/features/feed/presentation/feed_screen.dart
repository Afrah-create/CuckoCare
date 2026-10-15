import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/empty_state.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../data_platform/db/app_database.dart';
import '../data/feed_report_generator.dart';
import '../domain/feed_models.dart';
import 'feed_item_form_sheet.dart';
import 'feed_providers.dart';
import 'record_feed_transaction_sheet.dart';

// ── Provider for all-farm transactions (used by Transactions tab) ─────────────
final _allFeedTransactionsProvider =
    StreamProvider.family<List<_TxWithItem>, String>((ref, farmId) {
  final repo = ref.watch(feedRepositoryProvider);
  final itemsStream = repo.watchFeedItems(farmId);

  return itemsStream.asyncExpand((items) {
    final itemById = {for (final i in items) i.id: i};
    return repo.watchAllTransactions(farmId).map(
          (txs) => txs
              .map((tx) => _TxWithItem(tx: tx, item: itemById[tx.feedItemId]))
              .toList(),
        );
  });
});

class _TxWithItem {
  const _TxWithItem({required this.tx, this.item});
  final FeedTransactionRow tx;
  final FeedItemRow? item;
}

// ─────────────────────────────────────────────────────────────────────────────

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tabs,
      builder: (context, _) {
        return AppPage(
          primary: false,
          frame: false,
          title: 'Feed',
          actions: [
            // Stock tab: add feed item catalogue entry
            if (_tabs.index == 0)
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add feed item',
                onPressed: () => FeedItemFormSheet.show(context, ref),
              ),
          ],
          bottom: TabBar(
            controller: _tabs,
            tabs: const [
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Stock'),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Transactions'),
              Tab(icon: Icon(Icons.bar_chart_outlined), text: 'Report'),
            ],
          ),
          floatingActionButton: _tabs.index == 1
              ? _RecordFab(tabController: _tabs)
              : null,
          body: TabBarView(
            controller: _tabs,
            children: const [
              _StockTab(),
              _TransactionsTab(),
              _ReportTab(),
            ],
          ),
        );
      },
    );
  }
}

// ── FAB for Transactions tab ──────────────────────────────────────────────────

/// FAB on the Transactions tab. Shows a feed-item picker then the transaction
/// form — no need to navigate back to Stock first.
class _RecordFab extends ConsumerWidget {
  const _RecordFab({required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      heroTag: 'feed_tx_fab',
      onPressed: () => _pickItemAndRecord(context, ref),
      icon: const Icon(Icons.add),
      label: const Text('Record'),
    );
  }

  Future<void> _pickItemAndRecord(BuildContext context, WidgetRef ref) async {
    final stocks = ref.read(feedStockProvider).value ?? [];
    if (stocks.isEmpty) {
      AppSnack.show(
        context,
        message: 'Add a feed item first (Stock tab → + button).',
      );
      tabController.animateTo(0);
      return;
    }

    // If only one item, skip the picker.
    if (stocks.length == 1) {
      await RecordFeedTransactionSheet.show(
        context, ref, feedItem: stocks.first.feedItem,
      );
      return;
    }

    // Show a bottom-sheet item picker.
    if (!context.mounted) return;
    final picked = await showModalBottomSheet<FeedItem>(
      context: context,
      builder: (ctx) => _FeedItemPicker(stocks: stocks),
    );
    if (picked == null || !context.mounted) return;
    await RecordFeedTransactionSheet.show(context, ref, feedItem: picked);
  }
}

class _FeedItemPicker extends StatelessWidget {
  const _FeedItemPicker({required this.stocks});
  final List<FeedMetrics> stocks;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // handle
          Center(
            child: Container(
              width: 32, height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
            child: Text('Which feed item?',
                style: context.text.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          for (final s in stocks)
            ListTile(
              leading: const Icon(Icons.restaurant_outlined),
              title: Text(s.feedItem.name),
              subtitle: Text(
                '${_fmtQty(s.currentQuantity)} ${s.feedItem.unit} in stock',
                style: TextStyle(
                  color: s.isOutOfStock
                      ? context.scheme.error
                      : s.isBelowReorderLevel
                          ? context.colors.warning
                          : context.colors.success,
                ),
              ),
              onTap: () => Navigator.of(context).pop(s.feedItem),
            ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  static String _fmtQty(double v) =>
      v.truncateToDouble() == v ? v.toInt().toString() : v.toStringAsFixed(1);
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 1 — Stock
// ═════════════════════════════════════════════════════════════════════════════

class _StockTab extends ConsumerWidget {
  const _StockTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockAsync = ref.watch(feedStockProvider);

    return AsyncStateView(
      value: stockAsync,
      skeleton: const ListSkeleton(),
      onRetry: () => ref.invalidate(feedStockProvider),
      builder: (stocks) {
        if (stocks.isEmpty) {
          return EmptyState(
            icon: Icons.restaurant_outlined,
            title: 'No feed items yet',
            message: 'Tap + to add your first feed type. Works offline.',
            actionLabel: 'Add feed',
            onAction: () => FeedItemFormSheet.show(context, ref),
          );
        }
        final lowStock = stocks.where((s) => s.isBelowReorderLevel).toList();
        return CustomScrollView(
          slivers: [
            if (lowStock.isNotEmpty)
              SliverToBoxAdapter(child: _LowStockBanner(count: lowStock.length)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg,
              ),
              sliver: SliverList.separated(
                itemCount: stocks.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
                itemBuilder: (ctx, i) => _StockCard(stock: stocks[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LowStockBanner extends StatelessWidget {
  const _LowStockBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.warningContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: colors.onWarningContainer, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              count == 1
                  ? '1 item is below its reorder level'
                  : '$count items are below their reorder levels',
              style: context.text.bodyMedium
                  ?.copyWith(color: colors.onWarningContainer,
                      fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockCard extends ConsumerWidget {
  const _StockCard({required this.stock});
  final FeedMetrics stock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.scheme;
    final colors = context.colors;
    final item = stock.feedItem;

    final stockColor = stock.isOutOfStock
        ? scheme.error
        : stock.isBelowReorderLevel
            ? colors.warning
            : colors.success;

    final qtyLabel = _fmt(stock.currentQuantity);

    return Card(
      elevation: AppSpacing.elevationCard,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.xs, AppSpacing.sm),
        child: Row(
          children: [
            _TypeBadge(feedType: item.feedType),
            const SizedBox(width: AppSpacing.sm),
            // Name + stock level
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: context.text.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(FeedTypes.label(item.feedType),
                          style: context.text.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                      const SizedBox(width: AppSpacing.xs),
                      Text('·',
                          style: context.text.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '$qtyLabel ${item.unit}',
                        style: context.text.bodySmall?.copyWith(
                            color: stockColor, fontWeight: FontWeight.w700),
                      ),
                      if (stock.isBelowReorderLevel) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          stock.isOutOfStock
                              ? Icons.error_outline
                              : Icons.warning_amber_rounded,
                          size: 14,
                          color: stockColor,
                        ),
                      ],
                      if (stock.isInconsistent) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Tooltip(
                          message: 'Ledger inconsistency — please review',
                          child: Icon(
                            Icons.info_outline,
                            size: 14,
                            color: context.scheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Explicit "+ Record" button — always visible
            FilledButton.tonal(
              onPressed: () =>
                  RecordFeedTransactionSheet.show(context, ref, feedItem: item),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 4),
                  Text('Record', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            // ⋮ edit / delete menu
            PopupMenuButton<_CardAction>(
              icon: const Icon(Icons.more_vert, size: 20),
              tooltip: 'Options',
              onSelected: (action) {
                switch (action) {
                  case _CardAction.edit:
                    FeedItemFormSheet.show(context, ref, existing: item);
                  case _CardAction.delete:
                    _confirmDelete(context, ref, item);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: _CardAction.edit,
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: _CardAction.delete,
                  child: ListTile(
                    leading: Icon(Icons.delete_outline,
                        color: context.scheme.error),
                    title: Text('Delete',
                        style: TextStyle(color: context.scheme.error)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, FeedItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete feed item?'),
        content: Text(
          '"${item.name}" will be hidden. Transaction history is kept.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(feedRepositoryProvider).deleteFeedItem(item);
      if (context.mounted) AppSnack.success(context, '${item.name} removed');
    } catch (_) {
      if (context.mounted) {
        AppSnack.error(context, 'Could not delete. Please try again.');
      }
    }
  }

  static String _fmt(double v) =>
      v.truncateToDouble() == v ? v.toInt().toString() : v.toStringAsFixed(1);
}

enum _CardAction { edit, delete }

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.feedType});
  final String feedType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Icon(_icon(feedType),
          color: context.scheme.onSurfaceVariant, size: 22),
    );
  }

  IconData _icon(String type) => switch (type) {
        'starter' => Icons.egg_outlined,
        'grower' => Icons.trending_up_outlined,
        'finisher' => Icons.done_all_outlined,
        'layer' => Icons.layers_outlined,
        'chick' => Icons.spa_outlined,
        _ => Icons.restaurant_outlined,
      };
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 2 — Transactions
// ═════════════════════════════════════════════════════════════════════════════

class _TransactionsTab extends ConsumerWidget {
  const _TransactionsTab();

  static final _dateFmt = DateFormat('dd MMM yyyy');
  static final _tsFmt = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmId = ref.watch(primaryFarmProvider).value?.id;
    if (farmId == null) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No farm set up',
        message: 'Set up your farm to see transactions.',
      );
    }

    final txAsync = ref.watch(_allFeedTransactionsProvider(farmId));

    return AsyncStateView(
      value: txAsync,
      skeleton: const ListSkeleton(),
      onRetry: () => ref.invalidate(_allFeedTransactionsProvider(farmId)),
      builder: (entries) {
        if (entries.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No transactions yet',
            message:
                'Use the + Record button below, or tap "Record" on any feed item in the Stock tab.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg,
          ),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (ctx, i) {
            final e = entries[i];
            final tx = e.tx;
            final kind = FeedTransactionKind.fromStorage(tx.kind);
            final isPositive = kind.stockSign > 0;
            final colors = context.colors;
            final scheme = context.scheme;
            final qty = tx.quantity;
            final qtyLabel =
                '${isPositive ? '+' : '−'}${_fmtQty(qty)} ${e.item?.unit ?? ''}';

            return Card(
              elevation: AppSpacing.elevationCard,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
                      child: Icon(_kindIcon(kind), size: 16,
                          color: isPositive
                              ? colors.onSuccessContainer
                              : scheme.onErrorContainer),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.item?.name ?? '—',
                              style: context.text.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(
                            '${kind.label} · '
                            '${_dateFmt.format(tx.occurredOn.toLocal())}',
                            style: context.text.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant),
                          ),
                          Text(
                            'Recorded ${_tsFmt.format(tx.createdAt.toLocal())}',
                            style: context.text.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(qtyLabel,
                        style: context.text.titleSmall?.copyWith(
                            color: isPositive ? colors.success : scheme.error,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _kindIcon(FeedTransactionKind k) => switch (k) {
        FeedTransactionKind.purchase => Icons.add_shopping_cart_outlined,
        FeedTransactionKind.consumption => Icons.restaurant_outlined,
        FeedTransactionKind.adjustment => Icons.tune_outlined,
        FeedTransactionKind.wastage => Icons.delete_outline,
      };

  static String _fmtQty(double v) =>
      v.truncateToDouble() == v ? v.toInt().toString() : v.toStringAsFixed(1);
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 3 — Report
// ═════════════════════════════════════════════════════════════════════════════

class _ReportTab extends ConsumerStatefulWidget {
  const _ReportTab();

  @override
  ConsumerState<_ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends ConsumerState<_ReportTab>
    with AutomaticKeepAliveClientMixin {
  // Keep the tab alive so the report doesn't re-load on tab switch.
  @override
  bool get wantKeepAlive => true;

  _ReportLoadState _loadState = const _ReportIdle();
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final farmId = ref.read(primaryFarmProvider).value?.id;
    if (farmId == null) {
      setState(() => _loadState = const _ReportError('No farm found.'));
      return;
    }
    setState(() => _loadState = const _ReportLoading());
    try {
      final data =
          await ref.read(feedRepositoryProvider).fetchReportData(farmId);
      setState(() => _loadState = _ReportLoaded(data));
    } catch (e) {
      setState(() => _loadState = _ReportError('$e'));
    }
  }

  Future<void> _export() async {
    final loaded = _loadState;
    if (loaded is! _ReportLoaded || _exporting) return;
    final farm = ref.read(primaryFarmProvider).value;
    setState(() => _exporting = true);
    try {
      final file = await FeedReportGenerator()
          .generate(loaded.data, farmName: farm?.name ?? 'Farm');
      if (!mounted) return;
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'CucoCare Feed Report — ${farm?.name ?? 'Farm'}',
        text:
            'Feed report generated on ${DateFormat('dd MMM yyyy HH:mm').format(loaded.data.generatedAt.toLocal())}',
      ));
      if (mounted) AppSnack.success(context, 'Report ready to share.');
    } catch (_) {
      if (mounted) {
        AppSnack.error(context, 'Could not generate report. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return switch (_loadState) {
      _ReportIdle() => const SizedBox.shrink(),
      _ReportLoading() =>
        const Center(child: CircularProgressIndicator()),
      _ReportError(:final message) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: context.scheme.error),
                const SizedBox(height: AppSpacing.md),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                FilledButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      _ReportLoaded(:final data) => _ReportBody(
          data: data,
          exporting: _exporting,
          onExport: _export,
          onRefresh: _load,
        ),
    };
  }
}

// ── Report load state types ───────────────────────────────────────────────────

sealed class _ReportLoadState {
  const _ReportLoadState();
}

class _ReportIdle extends _ReportLoadState {
  const _ReportIdle();
}

class _ReportLoading extends _ReportLoadState {
  const _ReportLoading();
}

class _ReportError extends _ReportLoadState {
  const _ReportError(this.message);
  final String message;
}

class _ReportLoaded extends _ReportLoadState {
  const _ReportLoaded(this.data);
  final FeedReportData data;
}

// ── Report body ───────────────────────────────────────────────────────────────

class _ReportBody extends StatelessWidget {
  const _ReportBody({
    required this.data,
    required this.exporting,
    required this.onExport,
    required this.onRefresh,
  });

  final FeedReportData data;
  final bool exporting;
  final VoidCallback onExport;
  final VoidCallback onRefresh;

  static final _tsFmt = DateFormat('dd MMM yyyy, HH:mm');

  @override
  Widget build(BuildContext context) {
    final items = data.items.cast<dynamic>();
    final transactions = data.transactions.cast<dynamic>();

    // Stock per item
    final stockById = <String, double>{};
    for (final i in items) stockById[i.id as String] = 0.0;
    for (final tx in transactions) {
      final kind = FeedTransactionKind.fromStorage(tx.kind as String?);
      final id = tx.feedItemId as String;
      stockById[id] = (stockById[id] ?? 0.0) +
          (kind.stockSign > 0 ? tx.quantity as double : -(tx.quantity as double));
    }

    // Totals by kind
    final totals = <String, ({int count, double qty})>{};
    for (final tx in transactions) {
      final label =
          FeedTransactionKind.fromStorage(tx.kind as String?).label;
      final prev = totals[label] ?? (count: 0, qty: 0.0);
      totals[label] = (
        count: prev.count + 1,
        qty: prev.qty + (tx.quantity as double),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
      children: [
        // Header card
        _Card(
          child: Row(
            children: [
              Icon(Icons.description_outlined, color: context.scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Feed Management Report',
                        style: context.text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      'Generated: ${_tsFmt.format(data.generatedAt.toLocal())}',
                      style: context.text.bodySmall?.copyWith(
                          color: context.scheme.onSurfaceVariant),
                    ),
                    Text(
                      '${items.length} items · ${transactions.length} transactions',
                      style: context.text.bodySmall?.copyWith(
                          color: context.scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: onRefresh,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Totals by kind
        _SectionTitle('By transaction type'),
        const SizedBox(height: AppSpacing.xs),
        _Card(
          child: Column(
            children: totals.entries
                .map((e) => _KindRow(
                      label: e.key,
                      count: e.value.count,
                      qty: e.value.qty,
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Stock snapshot
        _SectionTitle('Current stock'),
        const SizedBox(height: AppSpacing.xs),
        _Card(
          child: Column(
            children: [
              _HeaderRow(const ['Item', 'Stock', 'Unit', 'Status']),
              ...items.map((item) {
                final qty = stockById[item.id as String] ?? 0.0;
                final reorder = item.reorderLevel as double?;
                final status = qty <= 0
                    ? 'Out of stock'
                    : (reorder != null && qty <= reorder)
                        ? 'Low'
                        : 'OK';
                return _DataRow([
                  item.name as String,
                  _fmtQty(qty),
                  item.unit as String,
                  status,
                ]);
              }),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Recent 20 transactions
        _SectionTitle('Recent transactions'),
        const SizedBox(height: AppSpacing.xs),
        _Card(
          child: Column(
            children: [
              _HeaderRow(const ['Date', 'Item', 'Type', 'Qty', 'Recorded']),
              ...transactions.take(20).map((tx) {
                final itemById = {
                  for (final i in items) i.id as String: i,
                };
                return _DataRow([
                  DateFormat('dd/MM/yy')
                      .format((tx.occurredOn as DateTime).toLocal()),
                  itemById[tx.feedItemId as String]?.name as String? ?? '—',
                  FeedTransactionKind.fromStorage(tx.kind as String?).label,
                  _fmtQty(tx.quantity as double),
                  DateFormat('dd/MM HH:mm')
                      .format((tx.createdAt as DateTime).toLocal()),
                ]);
              }),
              if (transactions.length > 20)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Text(
                    '+ ${transactions.length - 20} more rows in the CSV',
                    style: context.text.bodySmall?.copyWith(
                        color: context.scheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Download button
        FilledButton.icon(
          onPressed: exporting ? null : onExport,
          icon: exporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.download_outlined),
          label: Text(exporting ? 'Preparing…' : 'Download / Share CSV'),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Opens in Excel, Google Sheets, or any spreadsheet app.',
          style: context.text.bodySmall
              ?.copyWith(color: context.scheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static String _fmtQty(double v) =>
      v.truncateToDouble() == v ? v.toInt().toString() : v.toStringAsFixed(2);
}

// ── Report sub-widgets ────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600));
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: child,
    );
  }
}

class _KindRow extends StatelessWidget {
  const _KindRow({required this.label, required this.count, required this.qty});
  final String label;
  final int count;
  final double qty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(_icon(label), size: 16, color: context.scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(label, style: context.text.bodySmall)),
          Text('$count ×',
              style: context.text.bodySmall
                  ?.copyWith(color: context.scheme.onSurfaceVariant)),
          const SizedBox(width: AppSpacing.sm),
          Text(_fmtQty(qty),
              style: context.text.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  IconData _icon(String l) => switch (l) {
        'Purchase' => Icons.add_shopping_cart_outlined,
        'Consumption' => Icons.restaurant_outlined,
        'Wastage' => Icons.delete_outline,
        _ => Icons.tune_outlined,
      };

  static String _fmtQty(double v) =>
      v.truncateToDouble() == v ? v.toInt().toString() : v.toStringAsFixed(2);
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow(this.cells);
  final List<String> cells;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: cells
            .asMap()
            .entries
            .map(
              (e) => Expanded(
                flex: e.key == 0 ? 2 : 1,
                child: Text(e.value,
                    style: context.text.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.scheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow(this.cells);
  final List<String> cells;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: cells
            .asMap()
            .entries
            .map(
              (e) => Expanded(
                flex: e.key == 0 ? 2 : 1,
                child: Text(e.value,
                    style: context.text.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ),
            )
            .toList(),
      ),
    );
  }
}
