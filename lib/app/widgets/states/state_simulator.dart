import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SimulatedLoad { loading, empty, error, offline, content }

class StateSimulatorState {
  const StateSimulatorState({
    this.simulateOffline = false,
    this.slowNetwork = false,
    this.forced = const {},
  });

  final bool simulateOffline;
  final bool slowNetwork;
  final Map<String, SimulatedLoad> forced;

  SimulatedLoad? forcedFor(String screenId) {
    if (simulateOffline) {
      return forced[screenId] ?? SimulatedLoad.offline;
    }
    return forced[screenId];
  }

  StateSimulatorState copyWith({
    bool? simulateOffline,
    bool? slowNetwork,
    Map<String, SimulatedLoad>? forced,
  }) {
    return StateSimulatorState(
      simulateOffline: simulateOffline ?? this.simulateOffline,
      slowNetwork: slowNetwork ?? this.slowNetwork,
      forced: forced ?? this.forced,
    );
  }
}

class StateSimulatorNotifier extends Notifier<StateSimulatorState> {
  @override
  StateSimulatorState build() => const StateSimulatorState();

  void setOffline(bool value) {
    state = state.copyWith(simulateOffline: value);
  }

  void setSlow(bool value) {
    state = state.copyWith(slowNetwork: value);
  }

  void force(String screenId, SimulatedLoad? load) {
    final next = Map<String, SimulatedLoad>.from(state.forced);
    if (load == null || load == SimulatedLoad.content) {
      next.remove(screenId);
    } else {
      next[screenId] = load;
    }
    state = state.copyWith(forced: next);
  }
}

final stateSimulatorProvider =
    NotifierProvider<StateSimulatorNotifier, StateSimulatorState>(
  StateSimulatorNotifier.new,
);

class StateSimulatorScope extends InheritedWidget {
  const StateSimulatorScope({
    required this.state,
    required super.child,
    super.key,
  });

  final StateSimulatorState state;

  static StateSimulatorState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StateSimulatorScope>()
        ?.state;
  }

  SimulatedLoad? forcedFor(String screenId) => state.forcedFor(screenId);

  bool get slowNetwork => state.slowNetwork;

  @override
  bool updateShouldNotify(StateSimulatorScope oldWidget) =>
      state.simulateOffline != oldWidget.state.simulateOffline ||
      state.slowNetwork != oldWidget.state.slowNetwork ||
      state.forced != oldWidget.state.forced;
}

class StateSimulatorBinder extends ConsumerWidget {
  const StateSimulatorBinder({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sim = ref.watch(stateSimulatorProvider);
    return StateSimulatorScope(state: sim, child: child);
  }
}
