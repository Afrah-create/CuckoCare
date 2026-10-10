import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/presentation/theme_mode_provider.dart';
import 'l10n/app_localizations.dart';
import 'layout/layout_profile.dart';
import 'layout/layout_scope.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_animation.dart';
import 'theme/themed_system_ui.dart';
import 'widgets/lifecycle_host.dart';

class CucoCareApp extends ConsumerWidget {
  const CucoCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'CucoCare',
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'cucocare',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      themeAnimationDuration: themeAnimationDurationForView(View.of(context)),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        return LayoutScope(
          tokens: tokensForContext(context),
          child: LifecycleHost(
            child: ThemedSystemUi(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}
