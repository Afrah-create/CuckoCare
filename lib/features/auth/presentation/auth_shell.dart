import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/lifecycle/app_lifecycle_service.dart';
import 'login_controller.dart';

/// Shared auth chrome: edge-to-edge background and scrollable card frame.
class AuthShell extends ConsumerStatefulWidget {
  const AuthShell({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends ConsumerState<AuthShell> {
  AppLifecycleService? _lifecycle;

  @override
  void initState() {
    super.initState();
    ref.listenManual(connectivityOnlineProvider, (_, next) {
      if (!mounted) {
        return;
      }
      ref
          .read(loginControllerProvider.notifier)
          .setOnline(next.value ?? true);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _lifecycle = ref.read(appLifecycleServiceProvider);
      _lifecycle!.registerOnInactive(_unfocus);
    });
  }

  @override
  void dispose() {
    _lifecycle?.unregisterOnInactive(_unfocus);
    super.dispose();
  }

  void _unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final bg = context.colors.authBackground;

    return ColoredBox(
      color: bg,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.08),
                    widget.child,
                    SizedBox(height: constraints.maxHeight * 0.06),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
