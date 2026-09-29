import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../data_platform/db/app_database.dart';
class AuthSnapshotRepository {
  AuthSnapshotRepository(this._db, {Clock? clock})
      : _clock = clock ?? SystemClock();

  final AppDatabase _db;
  final Clock _clock;

  Future<bool> hasSnapshot() async {
    final row = await (_db.select(_db.authSnapshot)).getSingleOrNull();
    return row != null;
  }

  Future<void> saveDemoSnapshot() async {
    final now = _clock.now();
    await _db.into(_db.authSnapshot).insertOnConflictUpdate(
          AuthSnapshotCompanion.insert(
            userId: newId(),
            email: const Value('demo@cucocare.local'),
            farmIdsJson: jsonEncode(<String>['demo-farm']),
            lastVerifiedAt: Value(now),
          ),
        );
  }

  Future<void> clear() async {
    await _db.delete(_db.authSnapshot).go();
  }
}
