import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityMonitor {
  Stream<bool> get onConnectivityHintChanged;

  Future<bool> hasConnectivityHint();
}

class ConnectivityPlusMonitor implements ConnectivityMonitor {
  ConnectivityPlusMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Stream<bool> get onConnectivityHintChanged async* {
    yield await hasConnectivityHint();
    await for (final results in _connectivity.onConnectivityChanged) {
      yield _isConnectedHint(results);
    }
  }

  @override
  Future<bool> hasConnectivityHint() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnectedHint(results);
  }

  bool _isConnectedHint(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }
}
