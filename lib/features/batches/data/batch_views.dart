import '../../../data_platform/db/app_database.dart';
import '../domain/batch_facts.dart';
import '../domain/calendar_date.dart';
import '../domain/loss_record.dart';
import 'schedule_dates.dart';

enum BatchListFilter { active, closed, all }

enum BatchSort { newest, name, age }

BatchFacts batchFactsFromRow(BatchRow row) {
  return BatchFacts(
    id: row.id,
    initialCount: row.initialCount,
    acquiredOn: dueOnFromStorage(row.acquiredOn),
    ageAtAcquisitionDays: row.ageAtAcquisitionDays,
    status: BatchStatus.fromStorage(row.status),
    closedOn: row.closedOn == null ? null : dueOnFromStorage(row.closedOn!),
  );
}

LossEntry lossEntryFromRow(MortalityRecordRow row) {
  return LossEntry(
    id: row.id,
    batchId: row.batchId,
    count: row.count,
    kind: LossKind.fromStorage(row.kind),
    suspectedCause: SuspectedCause.fromStorage(row.suspectedCause),
    occurredOn: dueOnFromStorage(row.occurredOn),
    createdAt: row.createdAt,
    notes: row.notes,
    editedAt: row.editedAt,
  );
}

/// One batch with its losses grouped by day and kind, and its next pending task.
class BatchSummaryData {
  const BatchSummaryData({
    required this.batch,
    required this.tallies,
    this.nextDueOn,
  });

  final BatchRow batch;
  final List<LossTally> tallies;
  final CalendarDate? nextDueOn;
}

class BatchDetailData {
  const BatchDetailData({required this.batch, required this.losses});

  final BatchRow batch;
  final List<MortalityRecordRow> losses;
}

class FarmLossRow {
  const FarmLossRow({required this.loss, required this.batchName});

  final MortalityRecordRow loss;
  final String batchName;
}
