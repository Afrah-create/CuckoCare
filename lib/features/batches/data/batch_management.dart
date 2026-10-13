import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../../../data_platform/db/app_database.dart';
import '../domain/batch_facts.dart';
import '../domain/batch_metrics.dart';
import '../domain/batch_permissions.dart';
import '../domain/batch_rules.dart';
import '../domain/calendar_date.dart';
import '../domain/loss_record.dart';
import 'batch_repository.dart';
import 'batch_views.dart';
import 'loss_repository.dart';

class BatchEdit {
  const BatchEdit({
    required this.name,
    required this.notes,
    required this.source,
    required this.initialCount,
    required this.acquiredOn,
    required this.ageAtAcquisitionDays,
  });

  final String name;
  final String? notes;
  final String? source;
  final int initialCount;
  final CalendarDate acquiredOn;
  final int ageAtAcquisitionDays;
}

/// What an edit will change, for the confirmation dialog.
class BatchEditImpact {
  const BatchEditImpact({
    required this.liveBefore,
    required this.liveAfter,
    required this.shiftDays,
    required this.pendingTasksToMove,
  });

  final int liveBefore;
  final int liveAfter;
  final int shiftDays;
  final int pendingTasksToMove;

  bool get changesLiveCount => liveBefore != liveAfter;
  bool get movesTasks => shiftDays != 0 && pendingTasksToMove > 0;
}

class BatchDeletion {
  const BatchDeletion({
    required this.groupId,
    required this.taskCount,
    required this.lossCount,
  });

  final String groupId;
  final int taskCount;
  final int lossCount;
}

/// Use-cases for batch lifecycle and losses. Each one checks role and rules,
/// then writes through the repositories (one transaction per operation).
class BatchManagement {
  BatchManagement({
    required BatchRepository batches,
    required LossRepository losses,
    required CalendarDate Function() today,
    required Future<FarmRole> Function(String farmId) roleOf,
  }) : _batches = batches,
       _losses = losses,
       _today = today,
       _roleOf = roleOf;

  final BatchRepository _batches;
  final LossRepository _losses;
  final CalendarDate Function() _today;
  final Future<FarmRole> Function(String farmId) _roleOf;

  Future<Result<MortalityRecordRow>> recordLoss({
    required String batchId,
    required LossDraft draft,
  }) {
    return _guard(() async {
      final ctx = await _load(batchId);
      if (ctx == null) {
        return const Error(NotFoundFailure('This batch no longer exists.'));
      }
      final denied = await _deny(ctx.batch.farmId, manage: false);
      if (denied != null) {
        return Error(denied);
      }
      final violation = LossRules.check(
        batch: ctx.facts,
        metrics: ctx.metrics,
        count: draft.count,
        occurredOn: draft.occurredOn,
        today: _today(),
      );
      if (violation != null) {
        return Error(ValidationFailure(violation.message));
      }
      final row = await _losses.insertLoss(
        farmId: ctx.batch.farmId,
        batchId: batchId,
        draft: draft,
      );
      return Success(row);
    });
  }

  Future<Result<MortalityRecordRow>> editLoss({
    required String lossId,
    required LossDraft draft,
  }) {
    return _guard(() async {
      final existing = await _losses.findLoss(lossId);
      if (existing == null || existing.deletedAt != null) {
        return const Error(
          NotFoundFailure('This loss record no longer exists.'),
        );
      }
      final ctx = await _load(existing.batchId);
      if (ctx == null) {
        return const Error(NotFoundFailure('This batch no longer exists.'));
      }
      final denied = await _deny(ctx.batch.farmId, manage: false);
      if (denied != null) {
        return Error(denied);
      }
      final violation = LossRules.check(
        batch: ctx.facts,
        metrics: ctx.metrics,
        count: draft.count,
        occurredOn: draft.occurredOn,
        today: _today(),
        replacing: lossEntryFromRow(existing),
      );
      if (violation != null) {
        return Error(ValidationFailure(violation.message));
      }
      return Success(await _losses.updateLoss(existing, draft));
    });
  }

  Future<Result<MortalityRecordRow>> deleteLoss(String lossId) {
    return _setLossDeleted(lossId, deleted: true);
  }

  Future<Result<MortalityRecordRow>> restoreLoss(String lossId) {
    return _setLossDeleted(lossId, deleted: false);
  }

  Future<Result<MortalityRecordRow>> _setLossDeleted(
    String lossId, {
    required bool deleted,
  }) {
    return _guard(() async {
      final existing = await _losses.findLoss(lossId);
      if (existing == null) {
        return const Error(
          NotFoundFailure('This loss record no longer exists.'),
        );
      }
      final batch = await _batches.findBatch(existing.batchId);
      if (batch == null || batch.deletedAt != null) {
        return const Error(NotFoundFailure('This batch no longer exists.'));
      }
      final denied = await _deny(batch.farmId, manage: false);
      if (denied != null) {
        return Error(denied);
      }
      if (batch.status == BatchStatus.closed.storage) {
        return const Error(ValidationFailure(BatchRules.closedReadOnly));
      }
      await _losses.setDeleted(existing, deleted: deleted);
      return Success(existing);
    });
  }

  /// Preview for the confirmation dialog. Does not write.
  Future<Result<BatchEditImpact>> previewEdit(String batchId, BatchEdit edit) {
    return _guard(() async {
      final ctx = await _load(batchId);
      if (ctx == null) {
        return const Error(NotFoundFailure('This batch no longer exists.'));
      }
      final violation = _checkEdit(ctx, edit);
      if (violation != null) {
        return Error(ValidationFailure(violation.message));
      }
      final shift = BatchRules.scheduleShiftDays(
        before: ctx.facts,
        acquiredOn: edit.acquiredOn,
        ageAtAcquisitionDays: edit.ageAtAcquisitionDays,
      );
      final pending = shift == 0
          ? 0
          : (await _batches.pendingTasks(batchId)).length;
      final after = BatchMetrics.compute(
        BatchFacts(
          id: batchId,
          initialCount: edit.initialCount,
          acquiredOn: edit.acquiredOn,
          ageAtAcquisitionDays: edit.ageAtAcquisitionDays,
        ),
        ctx.tallies,
        _today(),
      );
      return Success(
        BatchEditImpact(
          liveBefore: ctx.metrics.liveCount,
          liveAfter: after.liveCount,
          shiftDays: shift,
          pendingTasksToMove: pending,
        ),
      );
    });
  }

  /// Name, notes, source, initial count correction and date changes in one write.
  Future<Result<void>> updateBatchDetails(String batchId, BatchEdit edit) {
    return _guard(() async {
      final ctx = await _load(batchId);
      if (ctx == null) {
        return const Error(NotFoundFailure('This batch no longer exists.'));
      }
      final denied = await _deny(ctx.batch.farmId, manage: true);
      if (denied != null) {
        return Error(denied);
      }
      if (ctx.facts.isClosed) {
        return const Error(ValidationFailure(BatchRules.closedReadOnly));
      }
      final violation = _checkEdit(ctx, edit);
      if (violation != null) {
        return Error(ValidationFailure(violation.message));
      }
      await _batches.updateDetails(
        ctx.batch,
        name: edit.name,
        notes: edit.notes,
        source: edit.source,
        initialCount: edit.initialCount,
        acquiredOn: edit.acquiredOn,
        ageAtAcquisitionDays: edit.ageAtAcquisitionDays,
        shiftDays: BatchRules.scheduleShiftDays(
          before: ctx.facts,
          acquiredOn: edit.acquiredOn,
          ageAtAcquisitionDays: edit.ageAtAcquisitionDays,
        ),
      );
      return const Success(null);
    });
  }

  Future<Result<void>> correctInitialCount(String batchId, int initialCount) {
    return _guard(() async {
      final batch = await _batches.findBatch(batchId);
      if (batch == null || batch.deletedAt != null) {
        return const Error(NotFoundFailure('This batch no longer exists.'));
      }
      final facts = batchFactsFromRow(batch);
      return updateBatchDetails(
        batchId,
        BatchEdit(
          name: batch.name,
          notes: batch.notes,
          source: batch.source,
          initialCount: initialCount,
          acquiredOn: facts.acquiredOn,
          ageAtAcquisitionDays: batch.ageAtAcquisitionDays,
        ),
      );
    });
  }

  Future<Result<void>> closeBatch({
    required String batchId,
    required CalendarDate closedOn,
    required CloseReason? reason,
    String? note,
  }) {
    return _guard(() async {
      final ctx = await _load(batchId);
      if (ctx == null) {
        return const Error(NotFoundFailure('This batch no longer exists.'));
      }
      final denied = await _deny(ctx.batch.farmId, manage: true);
      if (denied != null) {
        return Error(denied);
      }
      final violation = BatchRules.checkClose(
        batch: ctx.facts,
        closedOn: closedOn,
        reason: reason,
        today: _today(),
        lastLossOn: ctx.metrics.lastLossOn,
      );
      if (violation != null) {
        return Error(ValidationFailure(violation.message));
      }
      await _batches.close(
        ctx.batch,
        closedOn: closedOn,
        reason: reason!.storage,
        note: note,
      );
      return const Success(null);
    });
  }

  Future<Result<void>> reopenBatch(String batchId) {
    return _guard(() async {
      final batch = await _batches.findBatch(batchId);
      if (batch == null || batch.deletedAt != null) {
        return const Error(NotFoundFailure('This batch no longer exists.'));
      }
      final denied = await _deny(batch.farmId, manage: true);
      if (denied != null) {
        return Error(denied);
      }
      if (batch.status != BatchStatus.closed.storage) {
        return const Success(null);
      }
      await _batches.reopen(batch);
      return const Success(null);
    });
  }

  Future<Result<BatchDeletion>> deleteBatch(String batchId) {
    return _guard(() async {
      final batch = await _batches.findBatch(batchId);
      if (batch == null || batch.deletedAt != null) {
        return const Error(NotFoundFailure('This batch no longer exists.'));
      }
      final denied = await _deny(batch.farmId, manage: true);
      if (denied != null) {
        return Error(denied);
      }
      final counts = await _batches.cascadeCounts(batchId);
      final groupId = await _batches.deleteCascade(batch);
      return Success(
        BatchDeletion(
          groupId: groupId,
          taskCount: counts.tasks,
          lossCount: counts.losses,
        ),
      );
    });
  }

  Future<Result<void>> restoreBatch(String groupId) {
    return _guard(() async {
      await _batches.restoreGroup(groupId);
      return const Success(null);
    });
  }

  RuleViolation? _checkEdit(_BatchContext ctx, BatchEdit edit) {
    if (edit.name.trim().isEmpty) {
      return const RuleViolation(RuleField.batch, 'Give the batch a name.');
    }
    final countViolation = BatchRules.checkInitialCount(
      initialCount: edit.initialCount,
      totalLosses: ctx.metrics.totalLosses,
    );
    if (countViolation != null) {
      return countViolation;
    }
    CalendarDate? earliest;
    for (final tally in ctx.tallies) {
      if (earliest == null || tally.occurredOn.compareTo(earliest) < 0) {
        earliest = tally.occurredOn;
      }
    }
    return BatchRules.checkDates(
      acquiredOn: edit.acquiredOn,
      ageAtAcquisitionDays: edit.ageAtAcquisitionDays,
      today: _today(),
      earliestLossOn: earliest,
    );
  }

  Future<_BatchContext?> _load(String batchId) async {
    final batch = await _batches.findBatch(batchId);
    if (batch == null || batch.deletedAt != null) {
      return null;
    }
    final losses = await _losses.lossesForBatch(batchId);
    final facts = batchFactsFromRow(batch);
    final tallies = [for (final l in losses) lossEntryFromRow(l).tally];
    return _BatchContext(
      batch: batch,
      facts: facts,
      tallies: tallies,
      metrics: BatchMetrics.compute(facts, tallies, _today()),
    );
  }

  Future<Failure?> _deny(String farmId, {required bool manage}) async {
    final permissions = BatchPermissions(await _roleOf(farmId));
    final reason = manage
        ? permissions.manageBlockedReason
        : permissions.recordLossBlockedReason;
    return reason == null ? null : PermissionFailure(reason);
  }

  Future<Result<T>> _guard<T>(Future<Result<T>> Function() body) async {
    try {
      return await body();
    } catch (error, stackTrace) {
      appLogger.e(
        'Batch operation failed',
        error: error,
        stackTrace: stackTrace,
      );
      return const Error(StorageFailure("Couldn't save. Please try again."));
    }
  }
}

class _BatchContext {
  const _BatchContext({
    required this.batch,
    required this.facts,
    required this.tallies,
    required this.metrics,
  });

  final BatchRow batch;
  final BatchFacts facts;
  final List<LossTally> tallies;
  final BatchMetrics metrics;
}
