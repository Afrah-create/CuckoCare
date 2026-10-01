import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/app_logo.dart';
import '../splash_controller.dart';
import '../splash_mark.dart';
import '../splash_timing.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  static const _hen = AssetImage('assets/brand/layers/hen_mask.png');
  static const _eggL = AssetImage('assets/brand/layers/egg_left_mask.png');
  static const _eggM = AssetImage('assets/brand/layers/egg_mid_mask.png');
  static const _eggR = AssetImage('assets/brand/layers/egg_right_mask.png');

  bool _started = false;
  bool _navigated = false;
  bool _postFrameScheduled = false;
  SplashController? _splashController;
  late AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: SplashTiming.idleBreathPeriodMs),
      lowerBound: SplashTiming.idleBreathMin,
      upperBound: SplashTiming.idleBreathMax,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _splashController?.disposeAnim();
    _breath.dispose();
    super.dispose();
  }

  Future<void> _startIntro() async {
    if (_started) {
      return;
    }
    _started = true;
    final controller = _splashController!;
    try {
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      await controller.initialize(
        vsync: this,
        reduceMotion: reduceMotion,
        providers: const [_hen, _eggL, _eggM, _eggR],
        context: context,
      );
    } catch (e, st) {
      debugPrint('Splash intro failed: $e\n$st');
      if (mounted) {
        controller.skipIntroAfterFailure();
      }
    }
  }

  void _maybeNavigate() {
    if (_navigated || !mounted) {
      return;
    }
    if (!ref.read(splashGateReadyProvider)) {
      return;
    }
    final auth = ref.read(hasAuthSnapshotProvider);
    if (auth.isLoading || auth.hasError) {
      return;
    }
    if (auth.value ?? false) {
      // Authed splash → /today is handled by go_router redirect only.
      return;
    }
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        const LoginRoute().go(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _splashController ??= ref.read(splashControllerProvider.notifier);
    final splash = ref.watch(splashControllerProvider);
    final bg = context.colors.splashBackground;

    ref.listen(hasAuthSnapshotProvider, (_, next) {
      if (next.hasError) {
        ref.read(splashControllerProvider.notifier).markBootstrapFailed();
      }
    });

    ref.listen(splashGateReadyProvider, (_, ready) {
      if (!ready) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _maybeNavigate();
        }
      });
    });

    if (!_postFrameScheduled) {
      _postFrameScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _startIntro();
        _maybeNavigate();
      });
    }

    final waitingBootstrap =
        splash.introDone && ref.watch(hasAuthSnapshotProvider).isLoading;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Center(
            child: splash.bootstrapFailed
                ? _Retry(onRetry: () {
                    ref.read(splashControllerProvider.notifier).retryBootstrap();
                  })
                : !splash.assetsReady
                    ? const SizedBox.shrink()
                    : waitingBootstrap
                        ? ScaleTransition(
                            scale: _breath,
                            child: SplashMark(
                              progress: 1,
                              henMask: _hen,
                              eggLeft: _eggL,
                              eggMid: _eggM,
                              eggRight: _eggR,
                              showWordmark: true,
                            ),
                          )
                        : splash.mode == SplashIntroMode.reducedMotion
                            ? const AppLogo(
                                size: AppLogoSize.large,
                                showWordmark: true,
                              )
                            : SplashMark(
                                progress: splash.progress,
                                henMask: _hen,
                                eggLeft: _eggL,
                                eggMid: _eggM,
                                eggRight: _eggR,
                                showWordmark:
                                    splash.mode == SplashIntroMode.full,
                              ),
          ),
        ),
      ),
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Could not load your farm data offline.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
