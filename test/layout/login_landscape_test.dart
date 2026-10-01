import 'package:cucocare/app/di/providers.dart';
import 'package:cucocare/app/layout/layout_profile.dart';
import 'package:cucocare/app/layout/layout_scope.dart';
import 'package:cucocare/app/l10n/app_localizations.dart';
import 'package:cucocare/app/theme/app_theme.dart';
import 'package:cucocare/core/config/env.dart';
import 'package:cucocare/features/auth/presentation/auth_shell.dart';
import 'package:cucocare/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login landscape 915x412 lays out without overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(915, 412));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const env = Env(
      supabaseUrl: 'https://test-project.supabase.co',
      supabaseAnonKey: 'test-anon-key',
      envName: 'dev',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [envProvider.overrideWithValue(env)],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            return LayoutScope(
              tokens: tokensFor(MediaQuery.sizeOf(context)),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const AuthShell(child: LoginScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });
}
