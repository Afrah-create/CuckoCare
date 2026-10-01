import 'package:cucocare/app/shell/tab_scroll_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('unregister can run during unmount (deferred microtask)', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(tabScrollRegistryProvider.notifier);
    notifier.register(0, () {});

    expect(() => notifier.unregister(0), returnsNormally);

    await Future<void>.delayed(Duration.zero);
    expect(container.read(tabScrollRegistryProvider), isEmpty);
  });
}
