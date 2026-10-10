import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/presentation/theme_mode_provider.dart';
import 'di/providers.dart';
import 'l10n/app_localizations.dart';
import 'layout/layout_inspector.dart';
import 'layout/layout_preview.dart';
import 'layout/layout_profile.dart';
import 'layout/layout_scope.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_animation.dart';
import 'theme/themed_system_ui.dart';
import 'widgets/lifecycle_host.dart';
import 'widgets/states/state_simulator.dart';

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
        final page = child ?? const SizedBox.shrink();
        final dev = ref.watch(envProvider).isDev;
        final preview = dev ? ref.watch(layoutPreviewProvider) : null;
        final showInspector = dev && ref.watch(layoutInspectorProvider);
        final media = preview == null
            ? null
            : MediaQuery.of(context).copyWith(
                size: preview.size,
                textScaler: TextScaler.linear(preview.textScale),
              );
        final tokens = media == null
            ? tokensForContext(context)
            : tokensFor(
                media.size,
                textScale: media.textScaler.scale(1),
                reducedMotion: media.disableAnimations,
                sideInset: media.viewPadding.left > media.viewPadding.right
                    ? media.viewPadding.left
                    : media.viewPadding.right,
              );

        Widget framed = page;
        if (preview != null && media != null) {
          framed = FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: preview.size.width,
              height: preview.size.height,
              child: page,
            ),
          );
        }
        if (showInspector) {
          framed = Stack(
            fit: StackFit.expand,
            children: [
              framed,
              const Align(
                alignment: Alignment.bottomLeft,
                child: LayoutInspectorBanner(),
              ),
            ],
          );
        }

        Widget scoped = StateSimulatorBinder(
          child: LayoutScope(
            tokens: tokens,
            child: LifecycleHost(
              child: ThemedSystemUi(child: framed),
            ),
          ),
        );
        if (media != null) {
          scoped = MediaQuery(data: media, child: scoped);
        }
        return scoped;
      },
    );
  }
}
