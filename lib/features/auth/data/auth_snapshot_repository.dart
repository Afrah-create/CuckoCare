import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/sync/sync_session_coordinator.dart';
import '../domain/app_role.dart';
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

  Future<String?> loadUserId() async {
    final row = await (_db.select(_db.authSnapshot)).getSingleOrNull();
    return row?.userId;
  }

  Future<AppRole> loadAppRole() async {
    final row = await (_db.select(_db.authSnapshot)).getSingleOrNull();
    if (row == null) {
      return AppRole.farmer;
    }
    return AppRole.fromWire(row.appRole);
  }

  Future<void> setAppRole(AppRole role) async {
    final row = await (_db.select(_db.authSnapshot)).getSingleOrNull();
    if (row == null) {
      return;
    }
    await (_db.update(_db.authSnapshot)).write(
      AuthSnapshotCompanion(appRole: Value(role.wireValue)),
    );
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

  Future<void> persistFromSupabaseUser(
    User user, {
    AppRole? appRole,
  }) async {
    final now = _clock.now();
    final prior = await (_db.select(_db.authSnapshot)).getSingleOrNull();
    final farmIdsJson = prior != null && prior.userId == user.id
        ? prior.farmIdsJson
        : jsonEncode(<String>[]);
    final roleWire = appRole?.wireValue ??
        user.userMetadata?['app_role'] as String? ??
        prior?.appRole ??
        AppRole.farmer.wireValue;
    await _db.into(_db.authSnapshot).insertOnConflictUpdate(
          AuthSnapshotCompanion.insert(
            id: const Value(_singletonId),
            userId: user.id,
            email: Value(user.email),
            phone: Value(user.phone),
            farmIdsJson: farmIdsJson,
            appRole: Value(AppRole.fromWire(roleWire).wireValue),
            lastVerifiedAt: Value(now),
          ),
        );
    await _db.syncDao.ensureScope('reference');
  }

  Future<void> alignSyncScopesForUser({
    required String userId,
    required List<String> farmScopeIds,
  }) {
    return SyncSessionCoordinator(_db).alignWithAccount(
      userId: userId,
      farmScopeIds: farmScopeIds,
    );
  }

  Future<void> clear() async {
    await SyncSessionCoordinator(_db).clearOnSignOut();
    await _db.delete(_db.authSnapshot).go();
  }
}
