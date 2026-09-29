import 'dart:math';

import 'package:cucocare/core/time/clock.dart';
import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:cucocare/data_platform/sync/cuco_care_sync_engine.dart';
import 'package:cucocare/features/batches/data/batch_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'memory_remote_sync_api.dart';

void main() {
  test('two devices converge on shared remote', () async {
    const seed = 42;
    final rng = Random(seed);
    final remote = MemoryRemoteSyncApi(online: true);
    final dbA = AppDatabase.forTesting(NativeDatabase.memory());
    final dbB = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await dbA.close();
      await dbB.close();
    });

    for (final db in [dbA, dbB]) {
      await db.syncDao.ensureScope('farm-1');
      await db.syncMetaDao.setValue('hydrated', 'true');
    }

    final repoA = BatchRepository(dbA, FixedClock(DateTime.utc(2026, 1, 1)));
    final repoB = BatchRepository(dbB, FixedClock(DateTime.utc(2026, 1, 2)));

    final engineA = CucoCareSyncEngine(
      db: dbA,
      remote: remote,
      hasRealSession: () async => true,
    );
    final engineB = CucoCareSyncEngine(
      db: dbB,
      remote: remote,
      hasRealSession: () async => true,
    );

    for (var i = 0; i < 30; i++) {
      final onA = rng.nextBool();
      if (onA) {
        await repoA.createBatch(
          farmId: 'farm-1',
          name: 'A-$i',
          birdType: 'broiler',
          initialCount: 50 + i,
          acquiredOn: DateTime.utc(2026, 1, 1),
          programmeId: 'p',
          programmeVersion: 1,
        );
      } else {
        await repoB.createBatch(
          farmId: 'farm-1',
          name: 'B-$i',
          birdType: 'layer',
          initialCount: 40 + i,
          acquiredOn: DateTime.utc(2026, 1, 2),
          programmeId: 'p',
          programmeVersion: 1,
        );
      }
      remote.online = rng.nextDouble() > 0.2;
      if (rng.nextBool()) {
        await engineA.syncOnce();
      }
      if (rng.nextBool()) {
        await engineB.syncOnce();
      }
    }

    remote.online = true;
    await engineA.syncOnce();
    await engineB.syncOnce();

    final rowsA = await (dbA.select(dbA.batches)).get();
    final rowsB = await (dbB.select(dbB.batches)).get();
    expect(rowsA.length, rowsB.length, reason: 'seed=$seed');
    final namesA = rowsA.map((r) => r.name).toSet();
    final namesB = rowsB.map((r) => r.name).toSet();
    expect(namesA, namesB, reason: 'seed=$seed');
  });
}
