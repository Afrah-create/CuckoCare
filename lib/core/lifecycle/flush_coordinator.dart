import 'dart:async';

/// Something that can persist pending UI work without network I/O.
abstract interface class Flushable {
  Future<void> flush();
}

/// Invoked on [inactive], [hidden], and [paused] from [AppLifecycleService].
class FlushCoordinator {
  final _flushables = <Flushable>[];

  void register(Flushable flushable) {
    if (!_flushables.contains(flushable)) {
      _flushables.add(flushable);
    }
  }

  void unregister(Flushable flushable) {
    _flushables.remove(flushable);
  }

  Future<void> flushAll() async {
    final tasks = _flushables.map((f) => f.flush()).toList();
    await Future.wait(tasks);
  }
}
