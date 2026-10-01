import 'dart:async';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/connectivity_monitor.dart';
import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/supabase/offline_first_auth.dart';
import '../../../data_platform/sync/remote_sync_api.dart';
import '../../../data_platform/sync/sync_json.dart';
import '../../auth/data/auth_snapshot_repository.dart';

class FarmRepository {
  FarmRepository(
    this._db,
    this._snapshots, {
    Clock? clock,
    SupabaseClient? client,
    ConnectivityMonitor? connectivity,
    RemoteSyncApi? remoteSyncApi,
  })  : _clock = clock ?? SystemClock(),
        _client = client ?? Supabase.instance.client,
        _connectivity = connectivity ?? ConnectivityPlusMonitor(),
        _remote = remoteSyncApi;

  final AppDatabase _db;
  final AuthSnapshotRepository _snapshots;
  final Clock _clock;
  final SupabaseClient _client;
  final ConnectivityMonitor _connectivity;
  final RemoteSyncApi? _remote;

  /// Reactive read path — UI should watch this; sync/bootstrap updates Drift.
  Stream<FarmRow?> watchPrimaryFarm() {
    final query = _db.select(_db.farms)..where((f) => f.deletedAt.isNull());
    return query.watch().asyncMap(_pickPrimaryFarm);
  }

  Future<FarmRow?> primaryLocalFarm() async {
    final rows = await (_db.select(_db.farms)
          ..where((f) => f.deletedAt.isNull()))
        .get();
    return _pickPrimaryFarm(rows);
  }

  /// Farm ids for sync pull scopes: snapshot + any local-only farms (offline-first).
  Future<List<String>> mergeFarmScopeIds(List<String> serverFarmIds) async {
    final localIds = await allLocalFarmIds();
    final snapshotIds = await _snapshots.loadFarmIds();
    return {
      ...snapshotIds,
      ...serverFarmIds,
      ...localIds,
    }.toList();
  }

  Future<List<String>> allLocalFarmIds() async {
    final rows = await (_db.select(_db.farms)
          ..where((f) => f.deletedAt.isNull()))
        .get();
    return rows.map((r) => r.id).toList();
  }

  /// Keeps sync pull scopes aligned with Drift before push/pull (offline-created farms).
  Future<void> ensureSyncScopesAligned() async {
    final userId = await _snapshots.loadUserId();
    if (userId == null) {
      return;
    }
    final scopeIds = await mergeFarmScopeIds(const []);
    await _snapshots.setFarmIds(scopeIds);
    await _snapshots.alignSyncScopesForUser(
      userId: userId,
      farmScopeIds: scopeIds,
    );
  }

  Future<FarmRow?> _pickPrimaryFarm(List<FarmRow> rows) async {
    if (rows.isEmpty) {
      return null;
    }
    final ids = await _snapshots.loadFarmIds();
    for (final id in ids) {
      for (final row in rows) {
        if (row.id == id && row.serverVersion != null) {
          return row;
        }
      }
    }
    for (final id in ids) {
      for (final row in rows) {
        if (row.id == id) {
          return row;
        }
      }
    }
    rows.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return rows.first;
  }

  Future<void> cacheBootstrapData({
    required List<Map<String, dynamic>> farms,
    required List<Map<String, dynamic>> memberships,
  }) async {
    final now = _clock.now();
    await _db.transaction(() async {
      for (final f in farms) {
        final id = f['id'] as String;
        await _db.into(_db.farms).insertOnConflictUpdate(
              FarmsCompanion.insert(
                id: id,
                farmId: f['farm_id'] as String? ?? id,
                createdAt: _parseTime(f['created_at']) ?? now,
                updatedAt: _parseTime(f['updated_at']) ?? now,
                deletedAt: Value(_parseTime(f['deleted_at'])),
                serverVersion: Value(syncJsonInt(f['server_version'])),
                name: f['name'] as String,
                location: Value(f['location'] as String?),
                district: Value(f['district'] as String?),
                village: Value(f['village'] as String?),
                phone: Value(f['phone'] as String?),
                altPhone: Value(f['alt_phone'] as String?),
                notes: Value(f['notes'] as String?),
                profileCompletedAt: Value(_parseTime(f['profile_completed_at'])),
              ),
            );
      }
      for (final m in memberships) {
        final id = m['id'] as String? ?? newId();
        await _db.into(_db.farmMembers).insertOnConflictUpdate(
              FarmMembersCompanion.insert(
                id: id,
                farmId: m['farm_id'] as String,
                createdAt: _parseTime(m['created_at']) ?? now,
                updatedAt: _parseTime(m['updated_at']) ?? now,
                deletedAt: Value(_parseTime(m['deleted_at'])),
                serverVersion: Value(syncJsonInt(m['server_version'])),
                userId: m['user_id'] as String,
                role: m['role'] as String,
              ),
            );
      }
    });

    for (final f in farms) {
      final id = f['id'] as String;
      await _db.syncDao.ensureScope(id);
    }
  }

  /// Pushes a locally saved profile to Supabase when connectivity returns.
  Future<void> pushPendingFarmProfileToServer() async {
    final farm = await primaryLocalFarm();
    if (farm == null || farm.serverVersion != null) {
      return;
    }
    if (!await _connectivity.hasConnectivityHint()) {
      return;
    }
    if (!await ensureSupabaseSessionForNetwork()) {
      return;
    }

    try {
      await _syncLocalProfileToServer(farm);
    } catch (_) {
      // Sync will retry on next foreground/connectivity event.
    }
  }

  /// Creates a local-only farm row when the user has none yet (batch wizard).
  Future<String> ensureFarmNamed(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name');
    }
    final existing = await primaryLocalFarm();
    if (existing != null) {
      return existing.id;
    }
    final farmId = newId();
    final now = _clock.now();
    await _db.into(_db.farms).insert(
          FarmsCompanion.insert(
            id: farmId,
            farmId: farmId,
            createdAt: now,
            updatedAt: now,
            name: trimmed,
          ),
        );

    final userId =
        _client.auth.currentUser?.id ?? await _snapshots.loadUserId();
    if (userId != null) {
      await _db.into(_db.farmMembers).insert(
            FarmMembersCompanion.insert(
              id: newId(),
              farmId: farmId,
              createdAt: now,
              updatedAt: now,
              userId: userId,
              role: 'owner',
            ),
          );
    }
    await _db.syncDao.ensureScope(farmId);
    await _snapshots.addFarmId(farmId);
    return farmId;
  }

  /// Local-first write, then best-effort cloud RPC (offline-first).
  Future<String> saveFarmProfile({
    required String name,
    required String district,
    required String village,
    required String phone,
    String? altPhone,
    String? notes,
  }) async {
    final trimmedName = name.trim();
    final trimmedDistrict = district.trim();
    final trimmedVillage = village.trim();
    final trimmedPhone = phone.trim();

    final existing = await primaryLocalFarm();
    final localFarmId = existing?.id ?? newId();

    await _writeLocalFarmProfile(
      farmId: localFarmId,
      name: trimmedName,
      district: trimmedDistrict,
      village: trimmedVillage,
      phone: trimmedPhone,
      altPhone: altPhone,
      notes: notes,
      syncedToServer: false,
    );

    final online = await _connectivity.hasConnectivityHint();
    if (online && await ensureSupabaseSessionForNetwork()) {
      try {
        final farm = await primaryLocalFarm();
        if (farm != null) {
          await _syncLocalProfileToServer(farm);
        }
      } on AuthException {
        rethrow;
      } catch (e) {
        if (!_isLikelyConnectivityFailure(e)) {
          rethrow;
        }
      }
    }

    return (await primaryLocalFarm())?.id ?? localFarmId;
  }

  Future<void> _syncLocalProfileToServer(FarmRow farm) async {
    final serverFarmId = await _rpcSaveFarmProfile(
      name: farm.name,
      district: farm.district ?? '',
      village: farm.village ?? '',
      phone: farm.phone ?? '',
      altPhone: farm.altPhone,
      notes: farm.notes,
    );
    await _applyServerFarmId(localFarmId: farm.id, serverFarmId: serverFarmId);
    await (_db.update(_db.farms)..where((f) => f.id.equals(serverFarmId))).write(
      FarmsCompanion(
        serverVersion: const Value(1),
        updatedAt: Value(_clock.now()),
      ),
    );
    await _refreshFarmsFromServerBootstrap();
  }

  Future<void> _applyServerFarmId({
    required String localFarmId,
    required String serverFarmId,
  }) async {
    if (localFarmId == serverFarmId) {
      await _snapshots.addFarmId(serverFarmId);
      return;
    }

    final row = await (_db.select(_db.farms)
          ..where((f) => f.id.equals(localFarmId)))
        .getSingleOrNull();
    if (row == null) {
      await _snapshots.addFarmId(serverFarmId);
      return;
    }

    await _db.transaction(() async {
      await _db.into(_db.farms).insertOnConflictUpdate(
            FarmsCompanion.insert(
              id: serverFarmId,
              farmId: serverFarmId,
              createdAt: row.createdAt,
              updatedAt: _clock.now(),
              name: row.name,
              location: Value(row.location),
              district: Value(row.district),
              village: Value(row.village),
              phone: Value(row.phone),
              altPhone: Value(row.altPhone),
              notes: Value(row.notes),
              profileCompletedAt: Value(row.profileCompletedAt),
              serverVersion: const Value(1),
            ),
          );
      await _rekeyFarmId(localFarmId, serverFarmId);
      await (_db.delete(_db.farms)..where((f) => f.id.equals(localFarmId))).go();
    });

    await _migrateSyncScope(localFarmId, serverFarmId);
    await _db.syncDao.ensureScope(serverFarmId);
    final ids = await _snapshots.loadFarmIds();
    final withoutLocal = ids.where((id) => id != localFarmId).toList();
    if (!withoutLocal.contains(serverFarmId)) {
      await _snapshots.setFarmIds([...withoutLocal, serverFarmId]);
    } else {
      await _snapshots.setFarmIds(withoutLocal);
    }
  }

  Future<String> _rpcSaveFarmProfile({
    required String name,
    required String district,
    required String village,
    required String phone,
    String? altPhone,
    String? notes,
  }) async {
    final raw = await _client
        .rpc(
          'save_farm_profile',
          params: {
            'p_name': name,
            'p_district': district,
            'p_village': village,
            'p_phone': phone,
            'p_alt_phone': altPhone?.trim(),
            'p_notes': notes?.trim(),
          },
        )
        .timeout(const Duration(seconds: 25));
    return raw.toString();
  }

  Future<void> _rekeyFarmId(String fromFarmId, String toFarmId) async {
    if (fromFarmId == toFarmId) {
      return;
    }
    await (_db.update(_db.batches)..where((t) => t.farmId.equals(fromFarmId)))
        .write(BatchesCompanion(farmId: Value(toFarmId)));
    await (_db.update(_db.vaccinationTasks)
          ..where((t) => t.farmId.equals(fromFarmId)))
        .write(VaccinationTasksCompanion(farmId: Value(toFarmId)));
    await (_db.update(_db.feedItems)..where((t) => t.farmId.equals(fromFarmId)))
        .write(FeedItemsCompanion(farmId: Value(toFarmId)));
    await (_db.update(_db.feedTransactions)
          ..where((t) => t.farmId.equals(fromFarmId)))
        .write(FeedTransactionsCompanion(farmId: Value(toFarmId)));
    await (_db.update(_db.healthRecords)
          ..where((t) => t.farmId.equals(fromFarmId)))
        .write(HealthRecordsCompanion(farmId: Value(toFarmId)));
    await (_db.update(_db.mortalityRecords)
          ..where((t) => t.farmId.equals(fromFarmId)))
        .write(MortalityRecordsCompanion(farmId: Value(toFarmId)));
    await (_db.update(_db.farmEvents)..where((t) => t.farmId.equals(fromFarmId)))
        .write(FarmEventsCompanion(farmId: Value(toFarmId)));
    await (_db.update(_db.farmMembers)
          ..where((m) => m.farmId.equals(fromFarmId)))
        .write(FarmMembersCompanion(farmId: Value(toFarmId)));
    await (_db.update(_db.entitlements)
          ..where((t) => t.farmId.equals(fromFarmId)))
        .write(EntitlementsCompanion(farmId: Value(toFarmId)));
  }

  Future<void> _migrateSyncScope(String fromScope, String toScope) async {
    if (fromScope == toScope) {
      return;
    }
    final cursor = await _db.syncDao.cursorFor(fromScope);
    if (cursor > 0) {
      final existing = await _db.syncDao.cursorFor(toScope);
      if (cursor > existing) {
        await _db.syncDao.setCursor(toScope, cursor);
      }
    }
    await (_db.delete(_db.syncCursors)
          ..where((t) => t.syncTable.equals(fromScope)))
        .go();
  }

  Future<void> _writeLocalFarmProfile({
    required String farmId,
    required String name,
    required String district,
    required String village,
    required String phone,
    String? altPhone,
    String? notes,
    required bool syncedToServer,
  }) async {
    final now = _clock.now();
    final location = '$district, $village';

    final existing = await (_db.select(_db.farms)
          ..where((f) => f.id.equals(farmId)))
        .getSingleOrNull();

    await _db.into(_db.farms).insertOnConflictUpdate(
          FarmsCompanion.insert(
            id: farmId,
            farmId: farmId,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
            name: name,
            location: Value(location),
            district: Value(district),
            village: Value(village),
            phone: Value(phone),
            altPhone: Value(altPhone?.trim()),
            notes: Value(notes?.trim()),
            profileCompletedAt: Value(now),
            serverVersion: Value(syncedToServer ? 1 : null),
          ),
        );

    final userId =
        _client.auth.currentUser?.id ?? await _snapshots.loadUserId();
    if (userId != null) {
      final member = await (_db.select(_db.farmMembers)
            ..where(
              (m) =>
                  m.farmId.equals(farmId) &
                  m.userId.equals(userId) &
                  m.deletedAt.isNull(),
            ))
          .getSingleOrNull();
      final memberId = member?.id ?? newId();
      await _db.into(_db.farmMembers).insertOnConflictUpdate(
            FarmMembersCompanion.insert(
              id: memberId,
              farmId: farmId,
              createdAt: member?.createdAt ?? now,
              updatedAt: now,
              userId: userId,
              role: 'owner',
            ),
          );
    }

    await _db.syncDao.ensureScope(farmId);
    await _snapshots.addFarmId(farmId);
  }

  /// Refreshes farm rows and memberships from `sync_bootstrap` (profile lives here, not pull).
  Future<void> refreshBootstrapFromServer() async {
    await _refreshFarmsFromServerBootstrap();
  }

  Future<void> _refreshFarmsFromServerBootstrap() async {
    final remote = _remote;
    if (remote == null) {
      return;
    }
    final boot = await remote.bootstrap();
    await boot.when(
      success: (data) async {
        await cacheBootstrapData(
          farms: data.farms,
          memberships: data.memberships,
        );
        final serverIds = data.farms
            .map((f) => f['id'])
            .whereType<String>()
            .toList();
        final localIds = await _snapshots.loadFarmIds();
        final merged = {...localIds, ...serverIds}.toList();
        await _snapshots.setFarmIds(merged);
      },
      failure: (_) async {},
    );
  }

  bool _isLikelyConnectivityFailure(Object error) {
    final text = error.toString().toLowerCase();
    return error is TimeoutException ||
        text.contains('socket') ||
        text.contains('host lookup') ||
        text.contains('clientexception') ||
        text.contains('connection');
  }

  DateTime? _parseTime(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.tryParse(value.toString());
  }
}
