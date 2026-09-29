import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data_platform/db/app_database.dart';
import '../domain/user_profile.dart';

class AuthSnapshotRepository {
  AuthSnapshotRepository(this._db, {Clock? clock})
      : _clock = clock ?? SystemClock();

  final AppDatabase _db;
  final Clock _clock;

  Future<bool> hasSnapshot() async {
    final row = await (_db.select(_db.authSnapshot)).getSingleOrNull();
    return row != null;
  }

  Future<List<String>> loadFarmIds() async {
    final row = await (_db.select(_db.authSnapshot)).getSingleOrNull();
    if (row == null) {
      return [];
    }
    final decoded = jsonDecode(row.farmIdsJson);
    if (decoded is! List) {
      return [];
    }
    return decoded.map((e) => e.toString()).toList();
  }

  Future<void> setFarmIds(List<String> farmIds) async {
    final row = await (_db.select(_db.authSnapshot)).getSingleOrNull();
    if (row == null) {
      return;
    }
    await (_db.update(_db.authSnapshot)).write(
      AuthSnapshotCompanion(farmIdsJson: Value(jsonEncode(farmIds))),
    );
  }

  Future<void> addFarmId(String farmId) async {
    final ids = await loadFarmIds();
    if (ids.contains(farmId)) {
      return;
    }
    await setFarmIds([...ids, farmId]);
  }

  Future<UserProfile?> loadProfile() async {
    final row = await (_db.select(_db.authSnapshot)).getSingleOrNull();
    if (row == null) {
      return null;
    }
    final isDemo = row.email == 'demo@cucocare.local';
    return UserProfile(
      email: row.email,
      phone: row.phone,
      isDemo: isDemo,
    );
  }

  static const _singletonId = 1;

  Future<void> persistFromSupabaseUser(User user) async {
    final now = _clock.now();
    await _db.into(_db.authSnapshot).insertOnConflictUpdate(
          AuthSnapshotCompanion.insert(
            id: const Value(_singletonId),
            userId: user.id,
            email: Value(user.email),
            phone: Value(user.phone),
            farmIdsJson: jsonEncode(<String>[]),
            lastVerifiedAt: Value(now),
          ),
        );
    await _db.syncDao.ensureScope('reference');
  }

  Future<void> saveDemoSnapshot() async {
    final now = _clock.now();
    await _db.into(_db.authSnapshot).insertOnConflictUpdate(
          AuthSnapshotCompanion.insert(
            id: const Value(_singletonId),
            userId: newId(),
            email: const Value('demo@cucocare.local'),
            farmIdsJson: jsonEncode(<String>['demo-farm']),
            lastVerifiedAt: Value(now),
          ),
        );
    await _db.syncDao.ensureScope('demo-farm');
    await _db.syncDao.ensureScope('reference');
  }

  Future<void> clear() async {
    await _db.delete(_db.authSnapshot).go();
  }
}
