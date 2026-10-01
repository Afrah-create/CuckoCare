import 'package:flutter_test/flutter_test.dart';

import 'navigation_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Batches tab shows empty state and add batch entry', (tester) async {
    final container = createNavigationTestContainer(authed: true);
    addTearDown(container.dispose);

    await pumpCucoRouter(tester, container, initialLocation: '/batches');

    expect(find.text('No batches yet'), findsOneWidget);
    expect(find.text('Add batch'), findsOneWidget);
  });
}
