import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lets the shell scroll a tab's primary list to top on re-tap at root.
class TabScrollRegistry extends Notifier<Map<int, VoidCallback>> {
  @override
  Map<int, VoidCallback> build() => {};

  void register(int tabIndex, VoidCallback scrollToTop) {
    state = {...state, tabIndex: scrollToTop};
  }

  void unregister(int tabIndex) {
    final next = Map<int, VoidCallback>.from(state)..remove(tabIndex);
    state = next;
  }

  void scrollToTop(int tabIndex) => state[tabIndex]?.call();
}

final tabScrollRegistryProvider =
    NotifierProvider<TabScrollRegistry, Map<int, VoidCallback>>(
  TabScrollRegistry.new,
);
