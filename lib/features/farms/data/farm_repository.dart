import 'dart:async';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/connectivity_monitor.dart';
import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/supabase/offline_first_auth.dart';
import '../../../data_platform/sync/remote_sync_api.dart';
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

  Future<FarmRow?> primaryLocalFarm() async {
    final rows = await (_db.select(_db.farms)
          ..where((f) => f.deletedAt.isNull())
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
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
                serverVersion: Value((f['server_version'] as num?)?.toInt()),
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
                serverVersion: Value((m['server_version'] as num?)?.toInt()),
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
      await _rpcSaveFarmProfile(
        name: farm.name,
        district: farm.district ?? '',
        village: farm.village ?? '',
        phone: farm.phone ?? '',
        altPhone: farm.altPhone,
        notes: farm.notes,
      );
      await _refreshFarmsFromServerBootstrap();
    } catch (_) {
      // Sync will retry on next foreground/connectivity event.
    }
  }

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

    final online = await _connectivity.hasConnectivityHint();
    if (online && await ensureSupabaseSessionForNetwork()) {
      try {
        final farmId = await _rpcSaveFarmProfile(
          name: trimmedName,
          district: trimmedDistrict,
          village: trimmedVillage,
          phone: trimmedPhone,
          altPhone: altPhone,
          notes: notes,
        );
        await _writeLocalFarmProfile(
          farmId: farmId,
          name: trimmedName,
          district: trimmedDistrict,
          village: trimmedVillage,
          phone: trimmedPhone,
          altPhone: altPhone,
          notes: notes,
          syncedToServer: true,
        );
        return farmId;
      } on AuthException {
        rethrow;
      } catch (e) {
        if (!_isLikelyConnectivityFailure(e)) {
          rethrow;
        }
      }
    }

    final existing = await primaryLocalFarm();
    final farmId = existing?.id ?? newId();
    await _writeLocalFarmProfile(
      farmId: farmId,
      name: trimmedName,
      district: trimmedDistrict,
      village: trimmedVillage,
      phone: trimmedPhone,
      altPhone: altPhone,
      notes: notes,
      syncedToServer: false,
    );
    return farmId;
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

    await _db.into(_db.farms).insertOnConflictUpdate(
          FarmsCompanion.insert(
            id: farmId,
            farmId: farmId,
            createdAt: now,
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
      await _db.into(_db.farmMembers).insertOnConflictUpdate(
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
        final farmIds = data.farms
            .map((f) => f['id'])
            .whereType<String>()
            .toList();
        await _snapshots.setFarmIds(farmIds);
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
