import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/app_busy_indicator.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../data/feed_report_generator.dart';
import '../domain/feed_models.dart';

/// Screen that previews a feed report summary and lets the user download/share
/// it as a CSV file.
class FeedReportScreen extends ConsumerStatefulWidget {
  const FeedReportScreen({super.key});

  @override
  ConsumerState<FeedReportScreen> createState() => _FeedReportScreenState();
}

class _FeedReportScreenState extends ConsumerState<FeedReportScreen> {
  _ReportState _state = const _Idle();

  @override
  void initState() {
    super.initState();
    // Load data as soon as the screen opens.
    _load();
  }

  Future<void> _load() async {
    final farmId = ref.read(primaryFarmProvider).value?.id;
    if (farmId == null) {
      setState(() => _state = const _Error('No farm found.'));
      return;
    }
    setState(() => _state = const _Loading());
    try {
      final data = await ref
          .read(feedRepositoryProvider)
          .fetchReportData(farmId);
      setState(() => _state = _Loaded(data));
    } catch (e) {
      setState(() => _state = _Error('Failed to load feed data: $e'));
    }
  }

  Future<void> _download() async {
    final loaded = _state;
    if (loaded is! _Loaded) return;

    final farm = ref.read(primaryFarmProvider).value;
    final farmName = farm?.name ?? 'Farm';

    setState(() => _state = _Loaded(loaded.data, exporting: true));

    try {
      final file = await FeedReportGenerator().generate(
        loaded.data,
        farmName: farmName,
      );

      if (!mounted) return;

      // Share / save via Android share sheet
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          subject: 'CucoCare Feed Report — $farmName',
          text:
              'Feed management report generated on '
              '${DateFormat('dd MMM yyyy HH:mm').format(loaded.data.generatedAt.toLocal())}',
        ),
      );

      if (mounted) {
        AppSnack.success(context, 'Report ready to save or share.');
      }
    } catch (e) {
      if (mounted) {
        AppSnack.error(context, 'Could not generate report. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _state = _Loaded(loaded.data));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Feed Report',
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (_state is _Loaded)
          (_state as _Loaded).exporting
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: AppBusyIndicator(size: 20),
                )
              : IconButton(
                  icon: const Icon(Icons.download_outlined),
                  tooltip: 'Download / Share CSV',
                  onPressed: _download,
                ),
      ],
      body: switch (_state) {
        _Loading() => const ListSkeleton(),
        _Error(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: context.scheme.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: _load,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        _Loaded(:final data, :final exporting) => _ReportPreview(
            data: data,
            exporting: exporting,
            onDownload: _download,
          ),
        _Idle() => const SizedBox.shrink(),
      },
    );
  }
}

// ── State types ───────────────────────────────────────────────────────────────

sealed class _ReportState {
  const _ReportState();
}

class _Idle extends _ReportState {
  const _Idle();
}

class _Loading extends _ReportState {
  const _Loading();
}

class _Error extends _ReportState {
  const _Error(this.message);
  final String message;
}

class _Loaded extends _ReportState {
  const _Loaded(this.data, {this.exporting = false});
  final FeedReportData data;
  final bool exporting;
}

// ── Preview widget ────────────────────────────────────────────────────────────

class _ReportPreview extends ConsumerWidget {
  const _ReportPreview({
    required this.data,
    required this.exporting,
    required this.onDownload,
  });

  final FeedReportData data;
  final bool exporting;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = data.items.cast<dynamic>();
    final transactions = data.transactions.cast<dynamic>();
    final ts = DateFormat('dd MMM yyyy, HH:mm')
        .format(data.generatedAt.toLocal());

    // Compute summaries
    final summary = _buildSummary(data);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Meta
        _SectionCard(
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color: context.scheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Feed Management Report',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Generated: $ts',
              style: context.text.bodySmall?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${items.length} feed items · '
              '${transactions.length} transactions',
              style: context.text.bodySmall?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Totals by kind
        Text(
          'Summary by transaction type',
          style: context.text.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...summary.entries.map(
          (e) => _KindSummaryRow(
            label: e.key,
            count: e.value.count,
            totalQty: e.value.totalQty,
            totalCost: e.value.totalCost,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Stock snapshot
        Text(
          'Current stock snapshot',
          style: context.text.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _StockSnapshotTable(data: data),
        const SizedBox(height: AppSpacing.md),

        // Recent transactions
        Text(
          'Recent transactions',
          style: context.text.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _TransactionLogTable(data: data),
        const SizedBox(height: AppSpacing.xl),

        // Download button
        FilledButton.icon(
          onPressed: exporting ? null : onDownload,
          icon: exporting
              ? const AppBusyIndicator(size: 18)
              : const Icon(Icons.download_outlined),
          label: Text(exporting ? 'Preparing…' : 'Download / Share CSV'),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'The CSV file can be opened in Excel, Google Sheets, or any '
          'spreadsheet app.',
          style: context.text.bodySmall?.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  static Map<String, _KindTotals> _buildSummary(FeedReportData data) {
    final result = <String, _KindTotals>{};
    for (final tx in data.transactions.cast<dynamic>()) {
      final kind = FeedTransactionKind.fromStorage(tx.kind as String?);
      final label = kind.label;
      final existing = result[label] ?? _KindTotals();
      result[label] = _KindTotals(
        count: existing.count + 1,
        totalQty: existing.totalQty + (tx.quantity as double),
        totalCost: tx.unitCost != null
            ? existing.totalCost + (tx.unitCost as double) * (tx.quantity as double)
            : existing.totalCost,
      );
    }
    return result;
  }
}

class _KindTotals {
  _KindTotals({this.count = 0, this.totalQty = 0, this.totalCost = 0});
  final int count;
  final double totalQty;
  final double totalCost;
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _KindSummaryRow extends StatelessWidget {
  const _KindSummaryRow({
    required this.label,
    required this.count,
    required this.totalQty,
    required this.totalCost,
  });

  final String label;
  final int count;
  final double totalQty;
  final double totalCost;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(
            _kindIcon(label),
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label, style: context.text.bodyMedium),
          ),
          Text(
            '$count entries',
            style: context.text.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            _fmtQty(totalQty),
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _kindIcon(String label) => switch (label) {
        'Purchase' => Icons.add_shopping_cart_outlined,
        'Consumption' => Icons.restaurant_outlined,
        'Wastage' => Icons.delete_outline,
        _ => Icons.tune_outlined,
      };

  static String _fmtQty(double v) =>
      v.truncateToDouble() == v
          ? v.toInt().toString()
          : v.toStringAsFixed(2);
}

class _StockSnapshotTable extends StatelessWidget {
  const _StockSnapshotTable({required this.data});
  final FeedReportData data;

  @override
  Widget build(BuildContext context) {
    final items = data.items.cast<dynamic>();
    final transactions = data.transactions.cast<dynamic>();

    // Compute stock per item
    final stockById = <String, double>{};
    for (final i in items) {
      stockById[i.id as String] = 0.0;
    }
    for (final tx in transactions) {
      final kind = FeedTransactionKind.fromStorage(tx.kind as String?);
      final id = tx.feedItemId as String;
      final current = stockById[id] ?? 0.0;
      stockById[id] =
          current + (kind.stockSign > 0 ? tx.quantity as double : -(tx.quantity as double));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.scheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        children: [
          _TableRow(
            cells: const ['Feed Item', 'Stock', 'Unit', 'Status'],
            isHeader: true,
          ),
          for (final item in items) ...[
            const Divider(height: 1),
            _TableRow(
              cells: [
                item.name as String,
                _fmtQty(stockById[item.id] ?? 0),
                item.unit as String,
                _stockStatus(stockById[item.id] ?? 0, item.reorderLevel as double?),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _stockStatus(double qty, double? reorder) {
    if (qty <= 0) return 'Out of stock';
    if (reorder != null && qty <= reorder) return 'Low';
    return 'OK';
  }

  static String _fmtQty(double v) =>
      v.truncateToDouble() == v
          ? v.toInt().toString()
          : v.toStringAsFixed(2);
}

class _TransactionLogTable extends StatelessWidget {
  const _TransactionLogTable({required this.data});
  final FeedReportData data;

  static final _fmt = DateFormat('dd/MM/yy HH:mm');

  @override
  Widget build(BuildContext context) {
    final transactions = data.transactions.cast<dynamic>();
    final itemById = {
      for (final i in data.items.cast<dynamic>()) i.id as String: i,
    };

    final recent = transactions.take(20).toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.scheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        children: [
          _TableRow(
            cells: const ['Date', 'Item', 'Type', 'Qty', 'Recorded'],
            isHeader: true,
          ),
          for (final tx in recent) ...[
            const Divider(height: 1),
            _TableRow(
              cells: [
                DateFormat('dd/MM/yy').format(
                  (tx.occurredOn as DateTime).toLocal(),
                ),
                itemById[tx.feedItemId as String]?.name as String? ??
                    '—',
                FeedTransactionKind.fromStorage(tx.kind as String?).label,
                _fmtQty(tx.quantity as double),
                _fmt.format((tx.createdAt as DateTime).toLocal()),
              ],
            ),
          ],
          if (transactions.length > 20)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                '+ ${transactions.length - 20} more rows in the CSV download',
                style: context.text.bodySmall?.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  static String _fmtQty(double v) =>
      v.truncateToDouble() == v
          ? v.toInt().toString()
          : v.toStringAsFixed(2);
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.cells, this.isHeader = false});
  final List<String> cells;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final style = isHeader
        ? context.text.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.scheme.onSurfaceVariant,
          )
        : context.text.bodySmall;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(
              flex: i == 1 ? 2 : 1, // give item name more space
              child: Text(
                cells[i],
                style: style,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
        ],
      ),
    );
  }
}
