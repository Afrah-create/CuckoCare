import 'dart:async';
import 'dart:convert';

import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../db/app_database.dart';
import 'remote_sync_api.dart';
import 'sync_apply.dart';
import 'sync_engine.dart';

class CucoCareSyncEngine implements SyncEngine {
  CucoCareSyncEngine({
    required AppDatabase db,
    required RemoteSyncApi remote,
    required Future<bool> Function() hasRealSession,
    Future<void> Function()? onSuccessfulSync,
  })  : _db = db,
        _remote = remote,
        _hasRealSession = hasRealSession,
        _onSuccessfulSync = onSuccessfulSync,
        _apply = SyncApply(db);

  final AppDatabase _db;
  final RemoteSyncApi _remote;
  final Future<bool> Function() _hasRealSession;
  final Future<void> Function()? _onSuccessfulSync;
  final SyncApply _apply;

  final _statusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _status = const SyncStatus(phase: SyncPhase.idle, pendingOutboxCount: 0);
  bool _running = false;
  bool _runAgain = false;

  @override
  Stream<SyncStatus> get status => _statusController.stream;

  void _emit(SyncStatus next) {
    _status = next;
    if (!_statusController.isClosed) {
      _statusController.add(next);
    }
  }

  @override
  Future<void> fullResync() async {
    await _db.syncDao.resetAllCursors();
    await syncOnce(force: true);
  }

  @override
  Future<void> noteConnectivityOffline() async {
    final pending = await _db.outboxDao.pendingCount();
    final failed = await _db.outboxDao.failedCount();
    _emit(
      _status.copyWith(
        phase: SyncPhase.offline,
        pendingOutboxCount: pending,
        failedOutboxCount: failed,
        message: 'Offline',
      ),
    );
  }

  @override
  Future<Result<void>> syncOnce({bool force = false}) async {
    if (_running) {
      _runAgain = true;
      return const Success(null);
    }
    _running = true;
    try {
      return await _runSync(force: force);
    } finally {
      _running = false;
      if (_runAgain) {
        _runAgain = false;
        unawaited(syncOnce(force: true));
      }
    }
  }

  Future<Result<void>> _runSync({required bool force}) async {
    final pending = await _db.outboxDao.pendingCount();
    final failed = await _db.outboxDao.failedCount();
    _emit(_status.copyWith(pendingOutboxCount: pending, failedOutboxCount: failed));

    if (!await _hasRealSession()) {
      _emit(
        _status.copyWith(
          phase: SyncPhase.signedOutDemo,
          message: 'Demo session',
        ),
      );
      return const Error(SyncSignedOutDemo());
    }

    final ping = await _remote.ping();
    if (ping is Error<bool>) {
      _emit(_status.copyWith(phase: SyncPhase.offline, message: ping.failure.message));
      return Error(ping.failure);
    }

    _emit(_status.copyWith(phase: SyncPhase.syncing));

    final pushResult = await _pushLoop();
    if (pushResult is Error<void>) {
      await _handleSyncError(pushResult.failure);
      return pushResult;
    }

    final pullResult = await _pullLoop();
    if (pullResult is Error<void>) {
      await _handleSyncError(pullResult.failure);
      return pullResult;
    }

    final pendingAfter = await _db.outboxDao.pendingCount();
    final failedAfter = await _db.outboxDao.failedCount();
    _emit(
      SyncStatus(
        phase: SyncPhase.idle,
        pendingOutboxCount: pendingAfter,
        failedOutboxCount: failedAfter,
        lastSyncedAt: DateTime.now().toUtc(),
      ),
    );
    final after = _onSuccessfulSync;
    if (after != null) {
      await after();
    }
    return const Success(null);
  }

  Future<void> _handleSyncError(Failure failure) async {
    if (failure is SyncAuthRequired) {
      _emit(_status.copyWith(phase: SyncPhase.authRequired, message: failure.message));
    } else {
      _emit(_status.copyWith(phase: SyncPhase.error, message: failure.message));
    }
    await _logEvent('error', failure.message);
  }

  Future<Result<void>> _pushLoop() async {
    while (true) {
      final batch = await _db.outboxDao.claimBatch(limit: 100);
      if (batch.isEmpty) {
        return const Success(null);
      }

      final ops = batch
          .map(
            (row) => SyncPushOp(
              opId: row.opId,
              table: row.targetTable,
              rowId: row.rowId,
              op: row.op,
              payload: jsonDecode(row.payload) as Map<String, dynamic>,
              clientCreatedAt: row.createdAt,
            ),
          )
          .toList();

      final result = await _remote.push(ops);
      if (result is Error<SyncPushResponse>) {
        for (final row in batch) {
          await _db.outboxDao.markFailed(
            opId: row.opId,
            errorCode: 'network',
            retryable: true,
            message: result.failure.message,
          );
        }
        return Error(result.failure);
      }

      final response = (result as Success<SyncPushResponse>).value;
      await _maybeResetEpoch(response.epoch);

      for (final opResult in response.results) {
        if (opResult.status == 'applied' || opResult.status == 'duplicate') {
          await _db.outboxDao.markApplied(opResult.opId);
          if (opResult.row != null && opResult.serverVersion != null) {
            final table = ops.firstWhere((o) => o.opId == opResult.opId).table;
            await _apply.applyPushAck(
              table: table,
              row: opResult.row!,
              serverVersion: opResult.serverVersion!,
            );
          }
        } else {
          await _db.outboxDao.markFailed(
            opId: opResult.opId,
            errorCode: opResult.errorCode ?? 'rejected',
            retryable: opResult.retryable,
          );
        }
      }
    }
  }

  Future<Result<void>> _pullLoop() async {
    final bootstrap = await _ensureBootstrap();
    if (bootstrap is Error<void>) {
      return bootstrap;
    }

    final scopes = await _db.syncDao.allScopes();
    if (scopes.isEmpty) {
      return const Success(null);
    }

    final headResult = await _remote.head(scopes);
    if (headResult is Error<Map<String, int>>) {
      return Error(headResult.failure);
    }
    final heads = (headResult as Success<Map<String, int>>).value;
    await _maybeResetEpoch(heads['epoch'] ?? 0);

    var hydrated = 0;
    for (final scope in scopes) {
      if (scope == 'epoch') {
        continue;
      }
      final head = heads[scope] ?? 0;
      var cursor = await _db.syncDao.cursorFor(scope);
      if (head <= cursor) {
        continue;
      }

      var hasMore = true;
      while (hasMore) {
        final pageResult = await _remote.pull(scope: scope, since: cursor);
        if (pageResult is Error<SyncPullPage>) {
          return Error(pageResult.failure);
        }
        final page = (pageResult as Success<SyncPullPage>).value;
        await _db.transaction(() async {
          await _apply.applyPullPage(page.rows);
          cursor = page.nextCursor;
          await _db.syncDao.setCursor(scope, cursor);
        });
        hydrated += page.rows.length;
        _emit(_status.copyWith(hydrationProgress: hydrated));
        hasMore = page.hasMore;
      }
    }
    return const Success(null);
  }

  Future<Result<void>> _ensureBootstrap() async {
    final hydrated = await _db.syncMetaDao.getValue('hydrated');
    if (hydrated == 'true') {
      return const Success(null);
    }
    final boot = await _remote.bootstrap();
    if (boot is Error<SyncBootstrapData>) {
      return Error(boot.failure);
    }
    final data = (boot as Success<SyncBootstrapData>).value;
    await _maybeResetEpoch(data.epoch);
    for (final farm in data.farms) {
      final id = farm['id'] as String;
      await _db.syncDao.ensureScope(id);
    }
    await _db.syncDao.ensureScope('reference');
    for (final entry in data.heads.entries) {
      await _db.syncDao.setCursor(entry.key, entry.value);
    }
    await _db.syncMetaDao.setValue('hydrated', 'true');
    return const Success(null);
  }

  Future<void> _maybeResetEpoch(int epoch) async {
    final local = int.tryParse(await _db.syncMetaDao.getValue('epoch') ?? '1') ?? 1;
    if (epoch != 0 && epoch != local) {
      await _db.syncDao.resetAllCursors();
      await _db.syncMetaDao.setValue('epoch', '$epoch');
      await _logEvent('info', 'Epoch changed — cursors reset');
    }
  }

  Future<void> _logEvent(String level, String message) async {
    await _db.into(_db.syncEvents).insert(
          SyncEventsCompanion.insert(
            occurredAt: DateTime.now().toUtc(),
            level: level,
            message: message,
          ),
        );
    await _db.customStatement(
      'DELETE FROM sync_events WHERE id NOT IN (SELECT id FROM sync_events ORDER BY id DESC LIMIT 200)',
    );
  }

  void dispose() {
    unawaited(_statusController.close());
  }
}
