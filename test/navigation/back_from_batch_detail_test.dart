import 'package:flutter_test/flutter_test.dart';

import 'navigation_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Back from batch detail returns to batches list', (tester) async {
    final container = createNavigationTestContainer(authed: true);
    addTearDown(container.dispose);

    await pumpCucoRouter(tester, container, initialLocation: '/batches');

    expect(find.text('Sample batch (QA)'), findsOneWidget);

    await tester.tap(find.text('Sample batch (QA)'));
    await tester.pumpAndSettle();

    expect(find.text('Batch detail'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Sample batch (QA)'), findsOneWidget);
    expect(find.text('Batch detail'), findsNothing);
  });
}
