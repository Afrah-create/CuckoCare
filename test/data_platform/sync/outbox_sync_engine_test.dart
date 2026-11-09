import 'package:cucocare/core/error/result.dart';
import 'package:cucocare/core/time/clock.dart';
import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:cucocare/data_platform/db/synced_write.dart';
import 'package:cucocare/data_platform/sync/cuco_care_sync_engine.dart';
import 'package:cucocare/data_platform/sync/remote_sync_api.dart';
import 'package:cucocare/core/error/failure.dart';
import 'package:cucocare/features/batches/data/batch_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'memory_remote_sync_api.dart';

void main() {
  late AppDatabase db;
  late MemoryRemoteSyncApi remote;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    remote = MemoryRemoteSyncApi(online: true);
    await db.syncDao.ensureScope('farm-1');
    await db.syncMetaDao.setValue('hydrated', 'true');
  });

  tearDown(() async {
    await db.close();
  });

  test('writeSynced rolls back outbox when row write fails', () async {
    final write = SyncedWrite(db);
    await expectLater(
      write.writeSynced(
        writeRow: () async {
          throw StateError('boom');
        },
        table: 'batches',
        rowId: 'x',
        op: 'upsert',
        payload: const {'id': 'x'},
      ),
      throwsStateError,
    );
    expect(await db.outboxDao.pendingCount(), 0);
  });

  test('coalesces consecutive pending upserts for same row', () async {
    final write = SyncedWrite(db);
    for (var i = 0; i < 3; i++) {
      await write.writeSynced(
        writeRow: () async {},
        table: 'batches',
        rowId: 'row-1',
        op: 'upsert',
        payload: {'v': i},
      );
    }
    final rows = await db.select(db.outbox).get();
    expect(rows.length, 1);
  });

  test('engine push clears outbox and updates server_version', () async {
    final repo = BatchRepository(db, FixedClock(DateTime.utc(2026, 1, 1)));
    await repo.createBatch(
      farmId: 'farm-1',
      name: 'Batch A',
      birdType: 'broiler',
      initialCount: 100,
      acquiredOn: DateTime.utc(2026, 1, 1),
      programmeId: 'p1',
      programmeVersion: 1,
    );

    final engine = CucoCareSyncEngine(
      db: db,
      remote: remote,
      hasRealSession: () async => true,
    );

    final result = await engine.syncOnce();
    expect(result, isA<Success<void>>());
    expect(await db.outboxDao.pendingCount(), 0);

    final batch = await (db.select(db.batches)).getSingle();
    expect(batch.serverVersion, isNot(null));
  });

  test('applied without server_version keeps outbox with a new op_id', () async {
    final write = SyncedWrite(db);
    await write.writeSynced(
      writeRow: () async {},
      table: 'health_records',
      rowId: 'health-1',
      op: 'upsert',
      payload: const {'id': 'health-1', 'farm_id': 'farm-1'},
    );
    final before = (await db.select(db.outbox).get()).single.opId;
    final phantom = _PhantomApplyRemote();
    final engine = CucoCareSyncEngine(
      db: db,
      remote: phantom,
      hasRealSession: () async => true,
    );
    await engine.syncOnce();
    final after = await db.select(db.outbox).get();
    expect(after, hasLength(1));
    expect(after.single.opId, isNot(before));
    expect(after.single.state, 'pending');
  });

  test('demo session no-ops sync', () async {
    final engine = CucoCareSyncEngine(
      db: db,
      remote: remote,
      hasRealSession: () async => false,
    );
    final result = await engine.syncOnce();
    expect(result, isA<Error<void>>());
    expect((result as Error<void>).failure, isA<SyncSignedOutDemo>());
  });

  test('pull pagination hydrates remote rows', () async {
    remote.streams['farm-1'] = [
      for (var i = 1; i <= 3; i++)
        SyncPullRow(
          table: 'batches',
          serverVersion: i,
          row: {
            'id': 'remote-$i',
            'farm_id': 'farm-1',
            'name': 'R$i',
            'bird_type': 'broiler',
            'initial_count': 10,
            'acquired_on': '2026-01-01',
            'age_at_acquisition_days': 0,
            'status': 'active',
            'programme_id': 'p',
            'programme_version': 1,
            'created_at': '2026-01-01T00:00:00Z',
            'updated_at': '2026-01-01T00:00:00Z',
            'deleted_at': null,
            'server_version': i,
          },
        ),
    ];
    remote.heads['farm-1'] = 3;

    final engine = CucoCareSyncEngine(
      db: db,
      remote: remote,
      hasRealSession: () async => true,
    );
    await engine.syncOnce();
    expect(await db.syncDao.cursorFor('farm-1'), 3);
  });
}

class _PhantomApplyRemote extends MemoryRemoteSyncApi {
  @override
  Future<Result<SyncPushResponse>> push(List<SyncPushOp> ops) async {
    return Success(
      SyncPushResponse(
        results: [
          for (final op in ops)
            SyncPushOpResult(opId: op.opId, status: 'applied'),
        ],
        epoch: 1,
      ),
    );
  }
}
