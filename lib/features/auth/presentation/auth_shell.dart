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
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _entered = true);
      }
    });
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

  Future<void> _demoSession() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await ref.read(loginControllerProvider.notifier).continueWithDemoSession();
  }

  @override
  Widget build(BuildContext context) {
    final bg = context.colors.authBackground;
    final env = ref.watch(envProvider);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

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
                    AnimatedOpacity(
                      opacity: _entered || reduceMotion ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedSlide(
                        offset: _entered || reduceMotion
                            ? Offset.zero
                            : const Offset(0, 0.05),
                        duration: const Duration(milliseconds: 300),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.02),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: KeyedSubtree(
                            key: ValueKey(widget.child.runtimeType.toString()),
                            child: widget.child,
                          ),
                        ),
                      ),
                    ),
                    if (env.showDeveloperDemo) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _demoSession,
                        child: const Text('Developer: demo session'),
                      ),
                    ],
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
