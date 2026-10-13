import 'dart:async';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/connectivity_monitor.dart';
import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/db/synced_write.dart';
import '../../../data_platform/supabase/offline_first_auth.dart';
import '../../../data_platform/sync/remote_sync_api.dart';
import '../../../data_platform/sync/sync_json.dart';
import '../../auth/data/auth_snapshot_repository.dart';
import '../domain/farm_gps.dart';
import '../domain/farm_phone.dart';
import '../domain/farm_profile.dart';
import 'farm_synced_table.dart';

class FarmRepository {
  FarmRepository(
    this._db,
    this._snapshots, {
    Clock? clock,
    SupabaseClient? client,
    ConnectivityMonitor? connectivity,
    RemoteSyncApi? remoteSyncApi,
    SyncedWrite? syncedWrite,
  })  : _clock = clock ?? SystemClock(),
        _client = client ?? Supabase.instance.client,
        _connectivity = connectivity ?? ConnectivityPlusMonitor(),
        _remote = remoteSyncApi,
        _syncedWrite = syncedWrite ?? SyncedWrite(_db),
        _farmMapper = FarmSyncedTable();

  final AppDatabase _db;
  final AuthSnapshotRepository _snapshots;
  final Clock _clock;
  final SupabaseClient _client;
  final ConnectivityMonitor _connectivity;
  final RemoteSyncApi? _remote;
  final SyncedWrite _syncedWrite;
  final FarmSyncedTable _farmMapper;

  /// Reactive read path — UI should watch this; sync/bootstrap updates Drift.
  Stream<FarmRow?> watchPrimaryFarm() {
    final query = _db.select(_db.farms)..where((f) => f.deletedAt.isNull());
    return query.watch().asyncMap(_pickPrimaryFarm);
  }

  /// The signed-in user's role on [farmId], or null when no membership is stored.
  Future<String?> memberRole(String farmId) async {
    final userId = await _snapshots.loadUserId();
    if (userId == null) {
      return null;
    }
    final members = await (_db.select(_db.farmMembers)
          ..where(
            (m) =>
                m.farmId.equals(farmId) &
                m.userId.equals(userId) &
                m.deletedAt.isNull(),
          ))
        .get();
    return members.isEmpty ? null : members.first.role;
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
    final userId =
        _client.auth.currentUser?.id ?? await _snapshots.loadUserId();
    if (userId != null) {
      return allLocalFarmIdsForUser(userId);
    }
    final rows = await (_db.select(_db.farms)
          ..where((f) => f.deletedAt.isNull()))
        .get();
    return rows.map((r) => r.id).toList();
  }

  Future<List<String>> allLocalFarmIdsForUser(String userId) async {
    final members = await (_db.select(_db.farmMembers)
          ..where(
            (m) => m.userId.equals(userId) & m.deletedAt.isNull(),
          ))
        .get();
    if (members.isEmpty) {
      return [];
    }
    final farmIds = members.map((m) => m.farmId).toSet();
    final rows = await (_db.select(_db.farms)
          ..where((f) => f.deletedAt.isNull() & f.id.isIn(farmIds)))
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
    final ids = await _snapshots.loadFarmIds();
    return selectPrimaryFarm(rows, ids);
  }

  Future<FarmRow?> _farmById(String farmId) {
    return (_db.select(_db.farms)..where((f) => f.id.equals(farmId)))
        .getSingleOrNull();
  }

  Future<void> cacheBootstrapData({
    required List<Map<String, dynamic>> farms,
    required List<Map<String, dynamic>> memberships,
  }) async {
    final now = _clock.now();
    await _db.transaction(() async {
      for (final f in farms) {
        final id = f['id'] as String;
        final existing = await (_db.select(_db.farms)
              ..where((row) => row.id.equals(id)))
            .getSingleOrNull();
        final serverUpdatedAt = _parseTime(f['updated_at']) ?? now;
        final keep = existing != null &&
                !existing.updatedAt.isBefore(serverUpdatedAt)
            ? existing
            : null;
        await _db.into(_db.farms).insertOnConflictUpdate(
              FarmsCompanion.insert(
                id: id,
                farmId: f['farm_id'] as String? ?? id,
                createdAt: _parseTime(f['created_at']) ?? now,
                updatedAt: keep?.updatedAt ?? serverUpdatedAt,
                deletedAt: Value(_parseTime(f['deleted_at'])),
                serverVersion: Value(
                  keep != null
                      ? keep.serverVersion
                      : syncJsonInt(f['server_version']),
                ),
                name: keep?.name ?? f['name'] as String,
                location: Value(
                  keep != null ? keep.location : f['location'] as String?,
                ),
                district: Value(
                  keep != null ? keep.district : f['district'] as String?,
                ),
                village: Value(
                  keep != null ? keep.village : f['village'] as String?,
                ),
                phone: Value(
                  keep != null ? keep.phone : f['phone'] as String?,
                ),
                altPhone: Value(
                  keep != null ? keep.altPhone : f['alt_phone'] as String?,
                ),
                notes: Value(
                  keep != null ? keep.notes : f['notes'] as String?,
                ),
                profileCompletedAt: Value(
                  keep != null
                      ? keep.profileCompletedAt
                      : _parseTime(f['profile_completed_at']),
                ),
                latitude: Value(
                  keep != null
                      ? keep.latitude
                      : (f['latitude'] as num?)?.toDouble(),
                ),
                longitude: Value(
                  keep != null
                      ? keep.longitude
                      : (f['longitude'] as num?)?.toDouble(),
                ),
                locationAccuracyM: Value(
                  keep != null
                      ? keep.locationAccuracyM
                      : (f['location_accuracy_m'] as num?)?.toDouble(),
                ),
                locationCapturedAt: Value(
                  keep != null
                      ? keep.locationCapturedAt
                      : _parseTime(f['location_captured_at']),
                ),
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
    final normalizedPhone = normalizeUgandaPhone(phone.trim());

    final existing = await primaryLocalFarm();
    final localFarmId = existing?.id ?? newId();

    await _writeLocalFarmProfile(
      farmId: localFarmId,
      name: trimmedName,
      district: trimmedDistrict,
      village: trimmedVillage,
      phone: normalizedPhone,
      altPhone: altPhone,
      notes: notes,
      syncedToServer: false,
    );

    final online = await _connectivity.hasConnectivityHint();
    if (online && await ensureSupabaseSessionForNetwork()) {
      try {
        final farm = await _farmById(localFarmId);
        if (farm != null) {
          return await _syncLocalProfileToServer(farm);
        }
      } on AuthException {
        rethrow;
      } catch (e) {
        final farm = await _farmById(localFarmId);
        if (farm != null) {
          await _queueFarmProfileForSync(farm);
        }
        if (!_isLikelyConnectivityFailure(e)) {
          // Local profile is saved; sync will retry via outbox or next save.
        }
      }
    }

    return localFarmId;
  }

  /// Saves GPS coordinates locally and queues sync (for vet visits / assistance).
  Future<void> saveFarmGps({
    required String farmId,
    required FarmGpsReading reading,
  }) async {
    final existing = await (_db.select(_db.farms)
          ..where((f) => f.id.equals(farmId) & f.deletedAt.isNull()))
        .getSingleOrNull();
    if (existing == null) {
      throw StateError('Farm not found');
    }

    final now = _clock.now();
    final row = FarmRow(
      id: existing.id,
      farmId: existing.farmId,
      createdAt: existing.createdAt,
      updatedAt: now,
      deletedAt: existing.deletedAt,
      serverVersion: existing.serverVersion,
      name: existing.name,
      location: existing.location,
      district: existing.district,
      village: existing.village,
      phone: existing.phone,
      altPhone: existing.altPhone,
      notes: existing.notes,
      profileCompletedAt: existing.profileCompletedAt,
      latitude: reading.latitude,
      longitude: reading.longitude,
      locationAccuracyM: reading.accuracyMeters,
      locationCapturedAt: reading.capturedAt,
    );

    await _syncedWrite.writeSynced(
      writeRow: () => _db.into(_db.farms).insertOnConflictUpdate(
            FarmsCompanion(
              id: Value(row.id),
              farmId: Value(row.farmId),
              createdAt: Value(row.createdAt),
              updatedAt: Value(now),
              deletedAt: Value(row.deletedAt),
              serverVersion: Value(row.serverVersion),
              name: Value(row.name),
              location: Value(row.location),
              district: Value(row.district),
              village: Value(row.village),
              phone: Value(row.phone),
              altPhone: Value(row.altPhone),
              notes: Value(row.notes),
              profileCompletedAt: Value(row.profileCompletedAt),
              latitude: Value(row.latitude),
              longitude: Value(row.longitude),
              locationAccuracyM: Value(row.locationAccuracyM),
              locationCapturedAt: Value(row.locationCapturedAt),
            ),
          ),
      table: _farmMapper.tableName,
      rowId: farmId,
      op: 'upsert',
      payload: _farmMapper.toPayload(row),
    );
  }

  Future<String> _syncLocalProfileToServer(FarmRow farm) async {
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
    try {
      await _refreshFarmsFromServerBootstrap();
    } catch (_) {
      // Profile RPC succeeded; bootstrap refresh is best-effort.
    }
    return serverFarmId;
  }

  Future<void> _queueFarmProfileForSync(FarmRow row) async {
    await _syncedWrite.writeSynced(
      writeRow: () => _db.into(_db.farms).insertOnConflictUpdate(
            FarmsCompanion(
              id: Value(row.id),
              farmId: Value(row.farmId),
              createdAt: Value(row.createdAt),
              updatedAt: Value(_clock.now()),
              deletedAt: Value(row.deletedAt),
              serverVersion: Value(row.serverVersion),
              name: Value(row.name),
              location: Value(row.location),
              district: Value(row.district),
              village: Value(row.village),
              phone: Value(row.phone),
              altPhone: Value(row.altPhone),
              notes: Value(row.notes),
              profileCompletedAt: Value(row.profileCompletedAt),
              latitude: Value(row.latitude),
              longitude: Value(row.longitude),
              locationAccuracyM: Value(row.locationAccuracyM),
              locationCapturedAt: Value(row.locationCapturedAt),
            ),
          ),
      table: _farmMapper.tableName,
      rowId: row.id,
      op: 'upsert',
      payload: _farmMapper.toPayload(row),
    );
    await _db.syncDao.ensureScope(row.id);
    await _snapshots.addFarmId(row.id);
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
              latitude: Value(row.latitude),
              longitude: Value(row.longitude),
              locationAccuracyM: Value(row.locationAccuracyM),
              locationCapturedAt: Value(row.locationCapturedAt),
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
    return _parseRpcFarmId(raw);
  }

  static final _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static String _parseRpcFarmId(dynamic raw) {
    if (raw is String) {
      final id = raw.trim();
      if (_uuidPattern.hasMatch(id)) {
        return id;
      }
    }
    throw FormatException('Unexpected save_farm_profile response: $raw');
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
    await (_db.update(_db.vetAssistanceRequests)
          ..where((t) => t.farmId.equals(fromFarmId)))
        .write(VetAssistanceRequestsCompanion(farmId: Value(toFarmId)));
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
            latitude: Value(existing?.latitude),
            longitude: Value(existing?.longitude),
            locationAccuracyM: Value(existing?.locationAccuracyM),
            locationCapturedAt: Value(existing?.locationCapturedAt),
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
