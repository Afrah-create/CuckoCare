import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final engine = CucoCareSyncEngine(
    db: db,
    remote: remote,
    hasRealSession: () async {
      return Supabase.instance.client.auth.currentSession != null;
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
  final scheduler = SyncScheduler(
    engine: engine,
    connectivityHints: connectivity.onConnectivityHintChanged,
  );
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

final authSnapshotRepositoryProvider = Provider<AuthSnapshotRepository>(
  (ref) => AuthSnapshotRepository(ref.watch(appDatabaseProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(
    snapshotRepository: ref.watch(authSnapshotRepositoryProvider),
  );
});

final connectivityOnlineProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityMonitorProvider).onConnectivityHintChanged;
});

final hasAuthSnapshotProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(authSnapshotRepositoryProvider);
  return repo.hasSnapshot();
});
