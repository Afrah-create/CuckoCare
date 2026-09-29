import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/connectivity_monitor.dart';
import '../../core/time/clock.dart';
import '../../data_platform/db/app_database.dart';
import '../../data_platform/sync/outbox_sync_engine.dart';
import '../../data_platform/sync/remote_sync_api.dart';
import '../../data_platform/sync/supabase_remote_sync_api.dart';
import '../../data_platform/sync/sync_engine.dart';
import '../../data_platform/sync/sync_scheduler.dart';
import '../../features/auth/data/auth_snapshot_repository.dart';

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
  final connectivity = ref.watch(connectivityMonitorProvider);
  final engine = OutboxSyncEngine(
    db: db,
    remote: remote,
    isOnline: () async {
      final hint = await connectivity.hasConnectivityHint();
      if (!hint) {
        return false;
      }
      final ping = await remote.ping();
      return ping.valueOrNull ?? false;
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

final hasAuthSnapshotProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(authSnapshotRepositoryProvider);
  return repo.hasSnapshot();
});
