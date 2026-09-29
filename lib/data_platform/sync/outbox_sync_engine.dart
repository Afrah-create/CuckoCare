import 'dart:async';
import 'dart:convert';

import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../core/logging/app_logger.dart';
import '../db/app_database.dart';
import 'backoff.dart';
import 'remote_sync_api.dart';
import 'sync_engine.dart';

class OutboxSyncEngine implements SyncEngine {
  OutboxSyncEngine({
    required AppDatabase db,
    required RemoteSyncApi remote,
    required Future<bool> Function() isOnline,
    this.batchSize = 25,
    ExponentialBackoff? backoff,
  })  : _db = db,
        _remote = remote,
        _isOnline = isOnline,
        _backoff = backoff ?? ExponentialBackoff();

  final AppDatabase _db;
  final RemoteSyncApi _remote;
  final Future<bool> Function() _isOnline;
  final int batchSize;
  final ExponentialBackoff _backoff;

  final _statusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _status = const SyncStatus(
    phase: SyncPhase.idle,
    pendingOutboxCount: 0,
  );

  @override
  Stream<SyncStatus> get status => _statusController.stream;

  void _emit(SyncStatus next) {
    _status = next;
    if (!_statusController.isClosed) {
      _statusController.add(next);
    }
  }

  @override
  Future<Result<void>> syncOnce({bool force = false}) async {
    final online = await _isOnline();
    final pending = await _db.outboxDao.pendingCount();
    _emit(_status.copyWith(pendingOutboxCount: pending));

    if (!online) {
      _emit(
        _status.copyWith(
          phase: SyncPhase.offline,
          message: 'No network',
        ),
      );
      return const Error(SyncFailure('Offline'));
    }

    _emit(_status.copyWith(phase: SyncPhase.syncing));

    final pushResult = await _pushPending();
    if (pushResult is Error<void>) {
      _emit(
        _status.copyWith(
          phase: SyncPhase.error,
          message: pushResult.failure.message,
        ),
      );
      return pushResult;
    }

    final pullResult = await _pullAll();
    if (pullResult is Error<void>) {
      _emit(
        _status.copyWith(
          phase: SyncPhase.error,
          message: pullResult.failure.message,
        ),
      );
      return pullResult;
    }

    final remaining = await _db.outboxDao.pendingCount();
    _emit(
      SyncStatus(
        phase: SyncPhase.idle,
        pendingOutboxCount: remaining,
        lastSyncedAt: DateTime.now().toUtc(),
      ),
    );
    return const Success(null);
  }

  Future<Result<void>> _pushPending() async {
    while (true) {
      final batch = await _db.outboxDao.pending(limit: batchSize);
      if (batch.isEmpty) {
        return const Success(null);
      }

      final ops = batch
          .map(
            (row) => SyncPushOp(
              opId: row.opId,
              tableName: row.targetTable,
              rowId: row.rowId,
              op: row.op,
              payload: jsonDecode(row.payload) as Map<String, dynamic>,
            ),
          )
          .toList();

      final result = await _remote.push(ops);
      if (result is Error<SyncPushResult>) {
        for (final row in batch) {
          await _db.outboxDao.recordFailure(
            row.opId,
            result.failure.message,
            row.attempts + 1,
          );
        }
        await Future<void>.delayed(
          _backoff.delayForAttempt(batch.first.attempts + 1),
        );
        return Error(result.failure);
      }

      final ack = (result as Success<SyncPushResult>).value.acknowledgedOpIds;
      for (final opId in ack) {
        await _db.outboxDao.deleteOp(opId);
      }
    }
  }

  Future<Result<void>> _pullAll() async {
    const tables = ['batches', 'vaccination_tasks'];
    for (final table in tables) {
      var cursor = await _db.syncDao.cursorFor(table);
      var hasMore = true;
      while (hasMore) {
        final pageResult = await _remote.pull(
          tableName: table,
          cursor: cursor,
          pageSize: 50,
        );
        if (pageResult is Error<SyncPullPage>) {
          return Error(pageResult.failure);
        }
        final page = (pageResult as Success<SyncPullPage>).value;
        await _db.transaction(() async {
          for (final row in page.rows) {
            await _applyPullRow(row);
            if (row.serverVersion > cursor) {
              cursor = row.serverVersion;
            }
          }
          await _db.syncDao.setCursor(table, cursor);
        });
        hasMore = page.hasMore;
      }
    }
    return const Success(null);
  }

  Future<void> _applyPullRow(SyncPullRow row) async {
    // Minimal apply path for scaffold; extend per table as features land.
    appLogger.d('Applied pull ${row.tableName}/${row.rowId}');
  }

  Future<void> enqueueOutbox(OutboxCompanion entry) {
    return _db.into(_db.outbox).insert(entry);
  }

  void dispose() {
    unawaited(_statusController.close());
  }
}
