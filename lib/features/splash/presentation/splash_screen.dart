import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/theme/brand_tokens.dart';
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
    with SingleTickerProviderStateMixin {
  static const _hen = AssetImage('assets/brand/layers/hen_mask.png');
  static const _eggL = AssetImage('assets/brand/layers/egg_left_mask.png');
  static const _eggM = AssetImage('assets/brand/layers/egg_mid_mask.png');
  static const _eggR = AssetImage('assets/brand/layers/egg_right_mask.png');

  bool _started = false;
  bool _navigated = false;
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
    ref.read(splashControllerProvider.notifier).disposeAnim();
    _breath.dispose();
    super.dispose();
  }

  Future<void> _startIntro() async {
    if (_started) {
      return;
    }
    _started = true;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    await ref.read(splashControllerProvider.notifier).initialize(
          vsync: this,
          reduceMotion: reduceMotion,
          providers: const [_hen, _eggL, _eggM, _eggR],
          context: context,
        );
  }

  void _maybeNavigate() {
    if (_navigated) {
      return;
    }
    if (!ref.read(splashGateReadyProvider)) {
      return;
    }
    _navigated = true;
    final auth = ref.read(hasAuthSnapshotProvider);
    if (auth.hasError || !(auth.value ?? false)) {
      const LoginRoute().go(context);
      return;
    }
    const TodayRoute().go(context);
  }

  @override
  Widget build(BuildContext context) {
    final splash = ref.watch(splashControllerProvider);
    final brand = brandTokensOf(context);
    final bg = brand.splashBackgroundFor(Theme.of(context).brightness);

    ref.listen(hasAuthSnapshotProvider, (_, next) {
      if (next.hasError) {
        ref.read(splashControllerProvider.notifier).markBootstrapFailed();
      }
    });

    ref.listen(splashGateReadyProvider, (_, ready) {
      if (ready) {
        _maybeNavigate();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startIntro();
      _maybeNavigate();
    });

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
                            ? AppLogo(
                                size: AppLogoSize.large,
                                showWordmark: true,
                                heroTag: kEnableLogoHero ? 'app-logo' : null,
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
