import 'package:cucocare/app/theme/app_theme.dart';
import 'package:cucocare/app/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AppLogo exposes CucoCare semantics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(body: AppLogo()),
      ),
    );
    expect(find.bySemanticsLabel('CucoCare'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
