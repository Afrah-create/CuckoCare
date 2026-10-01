import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/providers.dart';
import '../time/kampala_today.dart';
import 'flush_coordinator.dart';

/// Single lifecycle observer for the app. Widgets must not add their own.
class AppLifecycleService {
  AppLifecycleService({
    required Ref ref,
    required FlushCoordinator flushCoordinator,
  })  : _ref = ref,
        _flush = flushCoordinator {
    _listener = AppLifecycleListener(
      onStateChange: _onStateChange,
    );
  }

  final Ref _ref;
  final FlushCoordinator _flush;
  late final AppLifecycleListener _listener;

  AppLifecycleState _state = AppLifecycleState.resumed;
  AppLifecycleState get state => _state;

  final _onInactiveCallbacks = <VoidCallback>[];

  void registerOnInactive(VoidCallback callback) {
    if (!_onInactiveCallbacks.contains(callback)) {
      _onInactiveCallbacks.add(callback);
    }
  }

  void unregisterOnInactive(VoidCallback callback) {
    _onInactiveCallbacks.remove(callback);
  }

  void _onStateChange(AppLifecycleState state) {
    _state = state;
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        for (final cb in List<VoidCallback>.of(_onInactiveCallbacks)) {
          cb();
        }
        unawaited(_flush.flushAll());
      case AppLifecycleState.resumed:
        _ref.read(lifecycleResumeCountProvider.notifier).onResume();
        unawaited(_ref.read(syncSchedulerProvider).onForeground());
      case AppLifecycleState.detached:
        break;
    }
  }

  void dispose() {
    _listener.dispose();
  }
}

final flushCoordinatorProvider = Provider<FlushCoordinator>((ref) {
  ref.keepAlive();
  return FlushCoordinator();
});

final appLifecycleServiceProvider = Provider<AppLifecycleService>((ref) {
  ref.keepAlive();
  final flush = ref.watch(flushCoordinatorProvider);
  final service = AppLifecycleService(ref: ref, flushCoordinator: flush);
  ref.onDispose(service.dispose);
  return service;
});
