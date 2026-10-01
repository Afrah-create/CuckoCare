import 'dart:async';

import '../supabase/offline_first_auth.dart';
import '../../core/network/connectivity_monitor.dart';
import 'sync_engine.dart';

class SyncScheduler {
  SyncScheduler({
    required SyncEngine engine,
    required ConnectivityMonitor connectivity,
    this.debounceAfterWrite = const Duration(seconds: 3),
    Future<void> Function()? beforeNetworkSync,
  })  : _engine = engine,
        _connectivity = connectivity,
        _beforeNetworkSync = beforeNetworkSync;

  final SyncEngine _engine;
  final ConnectivityMonitor _connectivity;
  final Future<void> Function()? _beforeNetworkSync;
  final Duration debounceAfterWrite;

  StreamSubscription<bool>? _connectivitySub;
  Timer? _debounce;

  Future<void> start() async {
    unawaited(_runSyncWhenOnline());
    _connectivitySub = _connectivity.onConnectivityHintChanged.listen((online) {
      if (online) {
        unawaited(_runSyncWhenOnline());
      } else {
        unawaited(_engine.noteConnectivityOffline());
      }
    });
  }

  void notifyLocalWrite() {
    _debounce?.cancel();
    _debounce = Timer(debounceAfterWrite, () {
      unawaited(_runSyncWhenOnline());
    });
  }

  Future<void> onForeground() => _runSyncWhenOnline();

  Future<void> _runSyncWhenOnline() async {
    if (!await _connectivity.hasConnectivityHint()) {
      await _engine.noteConnectivityOffline();
      return;
    }
    await ensureSupabaseSessionForNetwork();
    final beforeSync = _beforeNetworkSync;
    if (beforeSync != null) {
      await beforeSync();
    }
    await _engine.syncOnce();
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    _debounce?.cancel();
  }
}
