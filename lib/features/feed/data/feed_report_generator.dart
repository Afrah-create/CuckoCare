import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data_platform/db/app_database.dart';
import '../domain/feed_models.dart';

/// Builds a CSV feed management report and writes it to the app's temp
/// directory. Returns the [File] so callers can share it.
///
/// CSV columns:
///   Feed Item | Type | Unit | Date | Transaction | Quantity | Unit Cost | Batch | Updated At | Current Stock
class FeedReportGenerator {
  static final _dateFmt = DateFormat('dd/MM/yyyy');
  static final _tsFmt = DateFormat('dd/MM/yyyy HH:mm');

  Future<File> generate(
    FeedReportData data, {
    required String farmName,
  }) async {
    final items = data.items.cast<FeedItemRow>();
    final transactions = data.transactions.cast<FeedTransactionRow>();

    // Index items by id
    final itemById = {for (final i in items) i.id: i};

    // Compute current stock per item
    final stockById = <String, double>{};
    for (final i in items) {
      stockById[i.id] = 0.0;
    }
    for (final tx in transactions) {
      final kind = FeedTransactionKind.fromStorage(tx.kind);
      final current = stockById[tx.feedItemId] ?? 0.0;
      stockById[tx.feedItemId] =
          current + (kind.isPositive ? tx.quantity : -tx.quantity);
    }

    final buf = StringBuffer();

    // ── Header block ────────────────────────────────────────────────────────
    buf.writeln(_csvRow(['CucoCare Feed Management Report']));
    buf.writeln(_csvRow(['Farm', farmName]));
    buf.writeln(
        _csvRow(['Generated', _tsFmt.format(data.generatedAt.toLocal())]));
    buf.writeln();

    // ── Stock summary ────────────────────────────────────────────────────────
    buf.writeln(_csvRow(['--- STOCK SUMMARY ---']));
    buf.writeln(
      _csvRow([
        'Feed Item',
        'Type',
        'Unit',
        'Current Stock',
        'Reorder Level',
        'Status',
      ]),
    );
    for (final item in items) {
      final stock = stockById[item.id] ?? 0.0;
      final reorder = item.reorderLevel;
      final status = stock <= 0
          ? 'Out of stock'
          : (reorder != null && stock <= reorder)
              ? 'Low stock'
              : 'OK';
      buf.writeln(
        _csvRow([
          item.name,
          FeedTypes.label(item.feedType),
          item.unit,
          _fmtQty(stock),
          reorder != null ? _fmtQty(reorder) : '',
          status,
        ]),
      );
    }
    buf.writeln();

    // ── Transaction log ───────────────────────────────────────────────────
    buf.writeln(_csvRow(['--- TRANSACTION LOG ---']));
    buf.writeln(
      _csvRow([
        'Date',
        'Feed Item',
        'Type',
        'Transaction',
        'Quantity',
        'Unit',
        'Unit Cost (UGX)',
        'Total Cost (UGX)',
        'Batch',
        'Recorded At',
      ]),
    );

    for (final tx in transactions) {
      final item = itemById[tx.feedItemId];
      final kind = FeedTransactionKind.fromStorage(tx.kind);
      final totalCost =
          (tx.unitCost != null) ? tx.unitCost! * tx.quantity : null;

      buf.writeln(
        _csvRow([
          _dateFmt.format(tx.occurredOn.toLocal()),
          item?.name ?? tx.feedItemId,
          item != null ? FeedTypes.label(item.feedType) : '',
          kind.label,
          _fmtQty(tx.quantity),
          item?.unit ?? '',
          tx.unitCost != null ? _fmtQty(tx.unitCost!) : '',
          totalCost != null ? _fmtQty(totalCost) : '',
          tx.batchId ?? '',
          _tsFmt.format(tx.createdAt.toLocal()),
        ]),
      );
    }
    buf.writeln();

    // ── Per-item breakdown ────────────────────────────────────────────────
    buf.writeln(_csvRow(['--- PER-ITEM BREAKDOWN ---']));
    for (final item in items) {
      final itemTxs = transactions
          .where((t) => t.feedItemId == item.id)
          .toList();
      if (itemTxs.isEmpty) continue;

      buf.writeln(_csvRow([item.name]));
      buf.writeln(
        _csvRow([
          'Date',
          'Transaction',
          'Quantity',
          'Unit Cost (UGX)',
          'Recorded At',
          'Running Stock',
        ]),
      );

      var running = 0.0;
      // Walk oldest-first for running balance
      for (final tx in itemTxs.reversed) {
        final kind = FeedTransactionKind.fromStorage(tx.kind);
        if (kind.isPositive) {
          running += tx.quantity;
        } else {
          running -= tx.quantity;
        }
        buf.writeln(
          _csvRow([
            _dateFmt.format(tx.occurredOn.toLocal()),
            kind.label,
            _fmtQty(tx.quantity),
            tx.unitCost != null ? _fmtQty(tx.unitCost!) : '',
            _tsFmt.format(tx.createdAt.toLocal()),
            _fmtQty(running),
          ]),
        );
      }
      buf.writeln();
    }

    // ── Write file ────────────────────────────────────────────────────────
    final dir = await getTemporaryDirectory();
    final ts = DateFormat('yyyyMMdd_HHmm').format(data.generatedAt.toLocal());
    final file = File('${dir.path}/feed_report_$ts.csv');
    await file.writeAsString(buf.toString());
    return file;
  }

  /// Escapes a single CSV cell: wraps in quotes and escapes internal quotes.
  static String _csvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  static String _csvRow(List<String> cells) =>
      cells.map(_csvCell).join(',');

  static String _fmtQty(double v) =>
      v.truncateToDouble() == v ? v.toInt().toString() : v.toStringAsFixed(2);
}
