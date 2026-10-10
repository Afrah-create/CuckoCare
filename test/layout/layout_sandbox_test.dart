import 'package:cucocare/app/layout/layout_profile.dart';
import 'package:cucocare/app/layout/layout_sandbox.dart';
import 'package:cucocare/app/layout/layout_scope.dart';
import 'package:cucocare/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'device_profiles.dart';

void main() {
  for (final device in deviceProfiles) {
    testWidgets('sandbox fits ${device.name}', (tester) async {
      await tester.binding.setSurfaceSize(device.size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) {
            return LayoutScope(
              tokens: tokensFor(MediaQuery.sizeOf(context)),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const LayoutSandbox(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Primary action'), findsOneWidget);
    });
  }
}
