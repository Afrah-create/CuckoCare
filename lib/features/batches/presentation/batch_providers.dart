import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/time/kampala_today.dart';
import '../../../data_platform/db/app_database.dart';
import '../data/batch_views.dart';
import '../domain/batch_facts.dart';
import '../domain/batch_metrics.dart';
import '../domain/batch_planner.dart';
import '../domain/calendar_date.dart';
import '../domain/loss_record.dart';
import '../domain/programme_catalog.dart';
import '../domain/task_state_calculator.dart';

final todayDateProvider = Provider<CalendarDate>((ref) {
  return CalendarDate.fromDateTime(ref.watch(kampalaTodayProvider));
});

/// A batch with the metrics every screen reads.
class BatchSummary {
  const BatchSummary({
    required this.batch,
    required this.facts,
    required this.metrics,
    this.nextDueOn,
    this.nextDueState,
  });

  final BatchRow batch;
  final BatchFacts facts;
  final BatchMetrics metrics;
  final CalendarDate? nextDueOn;
  final TaskUiState? nextDueState;

  bool get isClosed => facts.isClosed;
}

class BatchView {
  const BatchView({
    required this.batch,
    required this.facts,
    required this.metrics,
    required this.losses,
    required this.rows,
  });

  final BatchRow batch;
  final BatchFacts facts;
  final BatchMetrics metrics;

  /// Newest first.
  final List<LossEntry> losses;
  final List<MortalityRecordRow> rows;

  bool get isClosed => facts.isClosed;
}

class BatchListQuery {
  const BatchListQuery({
    this.filter = BatchListFilter.active,
    this.search = '',
    this.sort = BatchSort.newest,
  });

  final BatchListFilter filter;
  final String search;
  final BatchSort sort;

  BatchListQuery copyWith({
    BatchListFilter? filter,
    String? search,
    BatchSort? sort,
  }) {
    return BatchListQuery(
      filter: filter ?? this.filter,
      search: search ?? this.search,
      sort: sort ?? this.sort,
    );
  }
}

/// Lives as long as the app, so filters survive rotation and tab switches.
class BatchListQueryNotifier extends Notifier<BatchListQuery> {
  @override
  BatchListQuery build() => const BatchListQuery();

  void setFilter(BatchListFilter filter) =>
      state = state.copyWith(filter: filter);

  void setSearch(String search) => state = state.copyWith(search: search);

  void setSort(BatchSort sort) => state = state.copyWith(sort: sort);
}

final batchListQueryProvider =
    NotifierProvider<BatchListQueryNotifier, BatchListQuery>(
      BatchListQueryNotifier.new,
    );

const _dueWindow = DueWindowConvention(
  defaultDaysBefore: 2,
  defaultDaysAfterOverdue: 3,
);

BatchSummary _summaryFrom(BatchSummaryData data, CalendarDate today) {
  final facts = batchFactsFromRow(data.batch);
  final nextDue = data.nextDueOn;
  return BatchSummary(
    batch: data.batch,
    facts: facts,
    metrics: BatchMetrics.compute(facts, data.tallies, today),
    nextDueOn: nextDue,
    nextDueState: nextDue == null || facts.isClosed
        ? null
        : const TaskStateCalculator(dueWindow: _dueWindow).state(
            status: PlannedTaskStatus.pending,
            enabled: true,
            dueOn: nextDue,
            today: today,
          ),
  );
}

List<BatchSummary> _sorted(List<BatchSummary> items, BatchSort sort) {
  final list = [...items];
  switch (sort) {
    case BatchSort.newest:
      list.sort((a, b) => b.batch.createdAt.compareTo(a.batch.createdAt));
    case BatchSort.name:
      list.sort(
        (a, b) =>
            a.batch.name.toLowerCase().compareTo(b.batch.name.toLowerCase()),
      );
    case BatchSort.age:
      list.sort((a, b) => b.metrics.ageDays.compareTo(a.metrics.ageDays));
  }
  return list;
}

/// Batches for the list screen, filtered, searched and sorted.
final batchSummariesProvider = StreamProvider<List<BatchSummary>>((ref) {
  final farmId = ref.watch(primaryFarmProvider).value?.id;
  if (farmId == null) {
    return Stream.value(const []);
  }
  final query = ref.watch(batchListQueryProvider);
  final today = ref.watch(todayDateProvider);
  return ref
      .watch(batchRepositoryProvider)
      .watchBatchSummaries(farmId, filter: query.filter, search: query.search)
      .map(
        (rows) => _sorted([
          for (final row in rows) _summaryFrom(row, today),
        ], query.sort),
      );
});

/// All batches on the farm (active and closed), newest first.
final allBatchSummariesProvider = StreamProvider<List<BatchSummary>>((ref) {
  final farmId = ref.watch(primaryFarmProvider).value?.id;
  if (farmId == null) {
    return Stream.value(const []);
  }
  final today = ref.watch(todayDateProvider);
  return ref
      .watch(batchRepositoryProvider)
      .watchBatchSummaries(farmId)
      .map(
        (rows) => _sorted([
          for (final row in rows) _summaryFrom(row, today),
        ], BatchSort.newest),
      );
});

class FarmBatchTotals {
  const FarmBatchTotals({
    required this.activeBatches,
    required this.closedBatches,
    required this.liveBirds,
  });

  final int activeBatches;
  final int closedBatches;
  final int liveBirds;
}

/// Totals for the list header and Today. Live birds count active batches only.
final farmBatchTotalsProvider = Provider<AsyncValue<FarmBatchTotals>>((ref) {
  return ref.watch(allBatchSummariesProvider).whenData((items) {
    var active = 0;
    var closed = 0;
    var live = 0;
    for (final item in items) {
      if (item.isClosed) {
        closed++;
      } else {
        active++;
        live += item.metrics.liveCount;
      }
    }
    return FarmBatchTotals(
      activeBatches: active,
      closedBatches: closed,
      liveBirds: live,
    );
  });
});

final batchViewProvider = StreamProvider.family<BatchView?, String>((
  ref,
  batchId,
) {
  final today = ref.watch(todayDateProvider);
  return ref.watch(batchRepositoryProvider).watchBatchDetail(batchId).map((
    data,
  ) {
    if (data == null) {
      return null;
    }
    final facts = batchFactsFromRow(data.batch);
    final entries = [for (final row in data.losses) lossEntryFromRow(row)]
      ..sort((a, b) => compareLossEntries(b, a));
    return BatchView(
      batch: data.batch,
      facts: facts,
      metrics: BatchMetrics.compute(facts, [
        for (final e in entries) e.tally,
      ], today),
      losses: entries,
      rows: data.losses,
    );
  });
});

final farmLossesProvider = StreamProvider.family<List<FarmLossRow>, String?>((
  ref,
  batchId,
) {
  final farmId = ref.watch(primaryFarmProvider).value?.id;
  if (farmId == null) {
    return Stream.value(const []);
  }
  return ref
      .watch(lossRepositoryProvider)
      .watchFarmLosses(farmId, batchId: batchId);
});

/// Id of the loss just saved, so its row can pulse once.
class HighlightedLossNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void mark(String? id) => state = id;
}

final highlightedLossProvider =
    NotifierProvider<HighlightedLossNotifier, String?>(
      HighlightedLossNotifier.new,
    );
