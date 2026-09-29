import 'dart:convert';

import 'package:cucocare/core/error/result.dart';
import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:cucocare/data_platform/sync/outbox_sync_engine.dart';
import 'package:cucocare/data_platform/sync/remote_sync_api.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_remote_sync_api.dart';

void main() {
  late AppDatabase db;
  late FakeRemoteSyncApi remote;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    remote = FakeRemoteSyncApi(online: true);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> enqueue(String opId) async {
    await db.into(db.outbox).insert(
          OutboxCompanion.insert(
            opId: opId,
            targetTable: 'batches',
            rowId: 'row-1',
            op: 'upsert',
            payload: jsonEncode({'id': 'row-1'}),
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        );
  }

  test('push retries after failure then succeeds', () async {
    remote.failNextPush = true;
    await enqueue('op-1');
    final engine = OutboxSyncEngine(db: db, remote: remote, isOnline: () async => true);

    final first = await engine.syncOnce();
    expect(first, isA<Error<void>>());
    expect(await db.outboxDao.pendingCount(), 1);

    remote.failNextPush = false;
    final second = await engine.syncOnce();
    expect(second, isA<Success<void>>());
    expect(await db.outboxDao.pendingCount(), 0);
    expect(remote.pushedOps.length, 1);
  });

  test('duplicate delivery is idempotent by op_id', () async {
    await enqueue('op-dup');
    remote.acknowledged.add('op-dup');
    final engine = OutboxSyncEngine(db: db, remote: remote, isOnline: () async => true);

    await engine.syncOnce();
    expect(await db.outboxDao.pendingCount(), 0);
  });

  test('offline then online transitions status', () async {
    await enqueue('op-2');
    remote.online = false;
    final engine = OutboxSyncEngine(db: db, remote: remote, isOnline: () async => remote.online);

    final offline = await engine.syncOnce();
    expect(offline, isA<Error<void>>());

    remote.online = true;
    final online = await engine.syncOnce();
    expect(online, isA<Success<void>>());
  });

  test('pull pagination advances cursor', () async {
    remote.pullData['batches'] = [
      SyncPullRow(
        tableName: 'batches',
        rowId: 'b1',
        serverVersion: 1,
        payload: {'id': 'b1'},
        deleted: false,
      ),
      SyncPullRow(
        tableName: 'batches',
        rowId: 'b2',
        serverVersion: 2,
        payload: {'id': 'b2'},
        deleted: false,
      ),
    ];
    final engine = OutboxSyncEngine(
      db: db,
      remote: _PagingRemote(remote),
      isOnline: () async => true,
    );

    await engine.syncOnce();
    expect(await db.syncDao.cursorFor('batches'), 2);
  });
}

class _PagingRemote implements RemoteSyncApi {
  _PagingRemote(this._inner);

  final FakeRemoteSyncApi _inner;

  @override
  Future<Result<bool>> ping() => _inner.ping();

  @override
  Future<Result<SyncPushResult>> push(List<SyncPushOp> ops) => _inner.push(ops);

  @override
  Future<Result<SyncPullPage>> pull({
    required String tableName,
    required int cursor,
    required int pageSize,
  }) async {
    final all = _inner.pullData[tableName] ?? [];
    final slice = all.where((r) => r.serverVersion > cursor).take(1).toList();
    return Success(
      SyncPullPage(
        rows: slice,
        hasMore: all.any((r) => r.serverVersion > (slice.lastOrNull?.serverVersion ?? cursor)),
      ),
    );
  }
}

extension _ListLastOrNull<E> on List<E> {
  E? get lastOrNull {
    if (length == 0) {
      return null;
    }
    return last;
  }
}
