import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/connectivity_monitor.dart';
import '../../core/time/clock.dart';
import '../../data_platform/db/app_database.dart';
import '../../data_platform/sync/cuco_care_sync_engine.dart';
import '../../data_platform/sync/remote_sync_api.dart';
import '../../data_platform/sync/supabase_remote_sync_api.dart';
import '../../data_platform/sync/sync_engine.dart';
import '../../data_platform/sync/sync_scheduler.dart';
import '../../features/auth/data/auth_snapshot_repository.dart';
import '../../features/auth/data/supabase_auth_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/domain/user_profile.dart';
import '../../features/farms/data/farm_repository.dart';
import '../../features/farms/domain/farm_profile.dart';

final envProvider = Provider<Env>((ref) => Env.fromEnvironment());

final clockProvider = Provider<Clock>((ref) => SystemClock());

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final connectivityMonitorProvider = Provider<ConnectivityMonitor>(
  (ref) => ConnectivityPlusMonitor(),
);

final remoteSyncApiProvider = Provider<RemoteSyncApi>(
  (ref) => SupabaseRemoteSyncApi(),
);

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final remote = ref.watch(remoteSyncApiProvider);
  final snapshots = ref.watch(authSnapshotRepositoryProvider);
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
    beforeNetworkSync: farms.pushPendingFarmProfileToServer,
  );
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

final authSnapshotRepositoryProvider = Provider<AuthSnapshotRepository>(
  (ref) => AuthSnapshotRepository(ref.watch(appDatabaseProvider)),
);

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  return FarmRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(authSnapshotRepositoryProvider),
    connectivity: ref.watch(connectivityMonitorProvider),
    remoteSyncApi: ref.watch(remoteSyncApiProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(
    snapshotRepository: ref.watch(authSnapshotRepositoryProvider),
    farmRepository: ref.watch(farmRepositoryProvider),
    remoteSyncApi: ref.watch(remoteSyncApiProvider),
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
  final repo = ref.watch(authSnapshotRepositoryProvider);
  return repo.loadProfile();
});

/// True when the user should see the farm profile banner (non-blocking).
final farmProfileIncompleteProvider = FutureProvider<bool>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  if (profile?.isDemo ?? false) {
    return false;
  }
  final farm = await ref.watch(farmRepositoryProvider).primaryLocalFarm();
  return !isFarmProfileComplete(farm);
});
