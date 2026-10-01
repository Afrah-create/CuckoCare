import 'package:cucocare/app/di/providers.dart';
import 'package:cucocare/app/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

import 'navigation_test_harness.dart';

void main() {
  test('GoRouter instance is stable when auth provider invalidates', () {
    final container = createNavigationTestContainer(authed: true);
    addTearDown(container.dispose);

    final first = container.read(appRouterProvider);
    container.read(hasAuthSnapshotProvider.notifier).adoptSignedOut();
    final second = container.read(appRouterProvider);

    expect(identical(first, second), isTrue);
  });
}
