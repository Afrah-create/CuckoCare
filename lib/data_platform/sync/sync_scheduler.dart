import 'dart:async';

import 'sync_engine.dart';

class SyncScheduler {
  SyncScheduler({
    required SyncEngine engine,
    required Stream<bool> connectivityHints,
    this.debounceAfterWrite = const Duration(seconds: 3),
  })  : _engine = engine,
        _connectivityHints = connectivityHints;

  final SyncEngine _engine;
  final Stream<bool> _connectivityHints;
  final Duration debounceAfterWrite;

  StreamSubscription<bool>? _connectivitySub;
  Timer? _debounce;

  Future<void> start() async {
    await _engine.syncOnce();
    _connectivitySub = _connectivityHints.listen((online) {
      if (online) {
        unawaited(_engine.syncOnce());
      }
    });
  }

  void notifyLocalWrite() {
    _debounce?.cancel();
    _debounce = Timer(debounceAfterWrite, () {
      unawaited(_engine.syncOnce());
    });
  }

  Future<void> onForeground() => _engine.syncOnce();

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    _debounce?.cancel();
  }
}
