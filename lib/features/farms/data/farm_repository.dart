import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../data_platform/db/app_database.dart';
import '../../auth/data/auth_snapshot_repository.dart';

class FarmRepository {
  FarmRepository(
    this._db,
    this._snapshots, {
    Clock? clock,
    SupabaseClient? client,
  })  : _clock = clock ?? SystemClock(),
        _client = client ?? Supabase.instance.client;

  final AppDatabase _db;
  final AuthSnapshotRepository _snapshots;
  final Clock _clock;
  final SupabaseClient _client;

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

  Future<String> saveFarmProfile({
    required String name,
    required String district,
    required String village,
    required String phone,
    String? altPhone,
    String? notes,
  }) async {
    final raw = await _client.rpc(
      'save_farm_profile',
      params: {
        'p_name': name.trim(),
        'p_district': district.trim(),
        'p_village': village.trim(),
        'p_phone': phone.trim(),
        'p_alt_phone': altPhone?.trim(),
        'p_notes': notes?.trim(),
      },
    );
    final farmId = raw.toString();
    final now = _clock.now();
    final location = '${district.trim()}, ${village.trim()}';

    await _db.into(_db.farms).insertOnConflictUpdate(
          FarmsCompanion.insert(
            id: farmId,
            farmId: farmId,
            createdAt: now,
            updatedAt: now,
            name: name.trim(),
            location: Value(location),
            district: Value(district.trim()),
            village: Value(village.trim()),
            phone: Value(phone.trim()),
            altPhone: Value(altPhone?.trim()),
            notes: Value(notes?.trim()),
            profileCompletedAt: Value(now),
          ),
        );

    final userId = _client.auth.currentUser?.id;
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
    return farmId;
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
