import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/connectivity_monitor.dart';
import '../../core/time/clock.dart';
import '../../data_platform/db/account_session.dart';
import '../../data_platform/db/app_database.dart';
import '../../data_platform/sync/cuco_care_sync_engine.dart';
import '../../data_platform/sync/remote_sync_api.dart';
import '../../data_platform/sync/supabase_remote_sync_api.dart';
import '../../data_platform/sync/sync_engine.dart';
import '../../data_platform/sync/sync_scheduler.dart';
import '../../features/auth/data/auth_snapshot_repository.dart';
import '../../features/auth/data/supabase_auth_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/domain/app_role.dart';
import '../../data_platform/db/synced_write.dart';
import '../../features/health/data/health_incident_photo_storage.dart';
import '../../features/health/data/health_repository.dart';
import '../../features/vet/data/vet_inbox_repository.dart';
import '../../features/vet/data/vet_directory_repository.dart';
import '../../features/vet/data/vet_location_repository.dart';
import '../../features/vet/data/vet_map_repository.dart';
import '../../features/auth/domain/user_profile.dart';
import '../../core/time/kampala_today.dart';
import '../../features/batches/data/batch_repository.dart';
import '../../features/farms/data/farm_gps_reader.dart';
import '../../features/farms/data/farm_repository.dart';
import '../../features/farms/domain/farm_profile.dart';

final envProvider = Provider<Env>((ref) => Env.fromEnvironment());

final clockProvider = Provider<Clock>((ref) => SystemClock());

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final userId = ref.watch(accountSessionProvider);
  final db = AppDatabase.forAccount(userId);
  ref.onDispose(() => disposeAppDatabase(db));
  return db;
});

final connectivityMonitorProvider = Provider<ConnectivityMonitor>(
  (ref) => ConnectivityPlusMonitor(),
);

final remoteSyncApiProvider = Provider<RemoteSyncApi>(
  (ref) => SupabaseRemoteSyncApi(),
);

final authSnapshotRepositoryProvider = Provider<AuthSnapshotRepository>(
  (ref) => AuthSnapshotRepository(ref.watch(appDatabaseProvider)),
);

final farmGpsReaderProvider = Provider<FarmGpsReader>(
  (ref) => DeviceFarmGpsReader(),
);

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  return FarmRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(authSnapshotRepositoryProvider),
    connectivity: ref.watch(connectivityMonitorProvider),
    remoteSyncApi: ref.watch(remoteSyncApiProvider),
    syncedWrite: ref.watch(syncedWriteProvider),
  );
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final remote = ref.watch(remoteSyncApiProvider);
  final snapshots = ref.watch(authSnapshotRepositoryProvider);
  final farms = ref.watch(farmRepositoryProvider);
  final engine = CucoCareSyncEngine(
    db: db,
    remote: remote,
    hasRealSession: () async {
      final profile = await snapshots.loadProfile();
      if (profile == null) {
        return false;
      }
      return !profile.isDemo;
    },
    onSuccessfulSync: () => farms.refreshBootstrapFromServer(),
  );
  ref.onDispose(engine.dispose);
  return engine;
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.status;
});

final syncSchedulerProvider = Provider<SyncScheduler>((ref) {
  final engine = ref.watch(syncEngineProvider);
  final connectivity = ref.watch(connectivityMonitorProvider);
  final farms = ref.watch(farmRepositoryProvider);
  final scheduler = SyncScheduler(
    engine: engine,
    connectivity: connectivity,
    beforeNetworkSync: () async {
      await farms.ensureSyncScopesAligned();
      await farms.pushPendingFarmProfileToServer();
      await ref.read(healthRepositoryProvider).flushAllPendingIncidentPhotos();
    },
  );
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(
    readSnapshots: () => AuthSnapshotRepository(ref.read(appDatabaseProvider)),
    readFarms: () => ref.read(farmRepositoryProvider),
    remoteSyncApi: ref.watch(remoteSyncApiProvider),
    activateAccount: (userId) =>
        ref.read(accountSessionProvider.notifier).activate(userId),
  );
});

final connectivityOnlineProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityMonitorProvider).onConnectivityHintChanged;
});

/// Local auth gate for routing. Use [HasAuthSnapshotNotifier.adoptAuthenticated]
/// after Drift writes to avoid a loading gap that can re-enter redirect twice.
class HasAuthSnapshotNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    ref.watch(authSnapshotRepositoryProvider);
    return ref.read(authSnapshotRepositoryProvider).hasSnapshot();
  }

  Future<void> refreshFromDisk() async {
    state = const AsyncLoading();
    state = AsyncData(
      await ref.read(authSnapshotRepositoryProvider).hasSnapshot(),
    );
  }

  void adoptAuthenticated() {
    state = const AsyncData(true);
  }

  void adoptSignedOut() {
    state = const AsyncData(false);
  }
}

final hasAuthSnapshotProvider =
    AsyncNotifierProvider<HasAuthSnapshotNotifier, bool>(
  HasAuthSnapshotNotifier.new,
);

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  ref.watch(hasAuthSnapshotProvider);
  final repo = ref.watch(authSnapshotRepositoryProvider);
  return repo.loadProfile();
});

final authUserIdProvider = FutureProvider<String?>((ref) async {
  ref.watch(hasAuthSnapshotProvider);
  final authed = ref.watch(hasAuthSnapshotProvider).value ?? false;
  if (!authed) {
    return null;
  }
  return ref.watch(authSnapshotRepositoryProvider).loadUserId();
});

final appRoleProvider = FutureProvider<AppRole>((ref) async {
  ref.watch(hasAuthSnapshotProvider);
  final authed = ref.watch(hasAuthSnapshotProvider).value ?? false;
  if (!authed) {
    return AppRole.farmer;
  }
  return ref.watch(authSnapshotRepositoryProvider).loadAppRole();
});

/// Primary farm from Drift — updates when local rows change or sync applies data.
final primaryFarmProvider = StreamProvider<FarmRow?>((ref) {
  return ref.watch(farmRepositoryProvider).watchPrimaryFarm();
});

/// True when the user should see the farm profile banner (non-blocking).
final farmProfileIncompleteProvider = Provider<bool>((ref) {
  final role = ref.watch(appRoleProvider).value;
  if (role == AppRole.vet) {
    return false;
  }
  final profile = ref.watch(userProfileProvider).value;
  if (profile?.isDemo ?? false) {
    return false;
  }
  final farm = ref.watch(primaryFarmProvider).value;
  return !isFarmProfileComplete(farm);
});

final syncedWriteProvider = Provider<SyncedWrite>((ref) {
  return SyncedWrite(ref.watch(appDatabaseProvider));
});

final batchRepositoryProvider = Provider<BatchRepository>((ref) {
  return BatchRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    syncedWrite: ref.watch(syncedWriteProvider),
  );
});

final healthIncidentPhotoStorageProvider = Provider<HealthIncidentPhotoStorage>(
  (ref) => HealthIncidentPhotoStorage(),
);

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncedWriteProvider),
    farms: ref.watch(farmRepositoryProvider),
    clock: ref.watch(clockProvider),
  );
});

final vetInboxRepositoryProvider = Provider<VetInboxRepository>((ref) {
  return VetInboxRepository();
});

final vetMapRepositoryProvider = Provider<VetMapRepository>((ref) {
  return VetMapRepository();
});

final vetDirectoryRepositoryProvider = Provider<VetDirectoryRepository>((ref) {
  return VetDirectoryRepository();
});

final vetLocationRepositoryProvider = Provider<VetLocationRepository>((ref) {
  return VetLocationRepository();
});

final activeBatchCountProvider = StreamProvider<int>((ref) {
  final farmId = ref.watch(primaryFarmProvider).value?.id;
  if (farmId == null) {
    return Stream.value(0);
  }
  return ref.watch(batchRepositoryProvider).watchActiveBatchCount(farmId);
});

final dueThisWeekCountProvider = StreamProvider<int>((ref) {
  final farmId = ref.watch(primaryFarmProvider).value?.id;
  if (farmId == null) {
    return Stream.value(0);
  }
  final today = ref.watch(kampalaTodayProvider);
  final start = DateTime.utc(today.year, today.month, today.day);
  return ref
      .watch(batchRepositoryProvider)
      .watchDueThisWeekCount(farmId, start);
});

final needsAttentionTasksProvider =
    StreamProvider<List<VaccinationTaskRow>>((ref) {
  final farmId = ref.watch(primaryFarmProvider).value?.id;
  if (farmId == null) {
    return Stream.value(const []);
  }
  final today = ref.watch(kampalaTodayProvider);
  final start = DateTime.utc(today.year, today.month, today.day);
  final end = start.add(const Duration(hours: 23, minutes: 59, seconds: 59));
  return ref
      .watch(batchRepositoryProvider)
      .watchNeedsAttention(farmId, start, end);
});
