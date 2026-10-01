import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/providers.dart';
import '../../core/config/app_version.dart';
import 'splash_intro_storage.dart';
import 'splash_timing.dart';

enum SplashIntroMode { full, quick, reducedMotion }

class SplashControllerState {
  const SplashControllerState({
    this.assetsReady = false,
    this.introDone = false,
    this.progress = 0,
    this.mode = SplashIntroMode.full,
    this.bootstrapFailed = false,
  });

  final bool assetsReady;
  final bool introDone;
  final double progress;
  final SplashIntroMode mode;
  final bool bootstrapFailed;

  SplashControllerState copyWith({
    bool? assetsReady,
    bool? introDone,
    double? progress,
    SplashIntroMode? mode,
    bool? bootstrapFailed,
  }) {
    return SplashControllerState(
      assetsReady: assetsReady ?? this.assetsReady,
      introDone: introDone ?? this.introDone,
      progress: progress ?? this.progress,
      mode: mode ?? this.mode,
      bootstrapFailed: bootstrapFailed ?? this.bootstrapFailed,
    );
  }
}

final splashIntroStorageProvider = Provider((ref) => SplashIntroStorage());

final splashControllerProvider =
    NotifierProvider<SplashController, SplashControllerState>(
  SplashController.new,
);

final splashIntroCompleteProvider = Provider<bool>((ref) {
  return ref.watch(splashControllerProvider).introDone;
});

final splashGateReadyProvider = Provider<bool>((ref) {
  final intro = ref.watch(splashIntroCompleteProvider);
  final auth = ref.watch(hasAuthSnapshotProvider);
  if (auth.hasError) {
    return intro;
  }
  return intro && !auth.isLoading;
});

class SplashController extends Notifier<SplashControllerState> {
  AnimationController? _anim;
  bool _initializing = false;

  @override
  SplashControllerState build() {
    ref.keepAlive();
    return const SplashControllerState();
  }

  void _onAnimTick() {
    final anim = _anim;
    if (anim == null) {
      return;
    }
    state = state.copyWith(progress: anim.value);
  }

  void _releaseAnim() {
    final anim = _anim;
    _anim = null;
    if (anim == null) {
      return;
    }
    anim.removeListener(_onAnimTick);
    anim.dispose();
  }

  Future<void> initialize({
    required TickerProvider vsync,
    required bool reduceMotion,
    required List<ImageProvider> providers,
    required BuildContext context,
  }) async {
    if (state.introDone) {
      state = state.copyWith(assetsReady: true, progress: 1);
      return;
    }
    if (_initializing) {
      return;
    }
    _initializing = true;
    try {
      for (final p in providers) {
        if (!context.mounted) {
          return;
        }
        await precacheImage(p, context);
      }

      final storage = ref.read(splashIntroStorageProvider);
      final full =
          !reduceMotion && await storage.shouldPlayFullIntro(kAppVersion);
      final mode = reduceMotion
          ? SplashIntroMode.reducedMotion
          : (full ? SplashIntroMode.full : SplashIntroMode.quick);

      state = state.copyWith(assetsReady: true, mode: mode);

      if (reduceMotion) {
        await Future<void>.delayed(
          const Duration(milliseconds: SplashTiming.reducedFadeMs),
        );
        await storage.markIntroSeen(kAppVersion);
        state = state.copyWith(introDone: true, progress: 1);
        return;
      }

      final durationMs = mode == SplashIntroMode.full
          ? SplashTiming.fullIntroMs
          : SplashTiming.quickIntroMs;

      _releaseAnim();
      final anim = AnimationController(
        vsync: vsync,
        duration: Duration(milliseconds: durationMs),
      );
      _anim = anim..addListener(_onAnimTick);

      try {
        await anim.forward();
      } catch (_) {
        _releaseAnim();
        rethrow;
      }

      if (_anim == null) {
        return;
      }

      await storage.markIntroSeen(kAppVersion);
      _releaseAnim();
      state = state.copyWith(introDone: true, progress: 1);
    } finally {
      _initializing = false;
    }
  }

  void markBootstrapFailed() {
    state = state.copyWith(bootstrapFailed: true);
  }

  /// Unblocks navigation when intro animation cannot run (e.g. ticker failure).
  void skipIntroAfterFailure() {
    state = state.copyWith(
      assetsReady: true,
      introDone: true,
      progress: 1,
      mode: SplashIntroMode.reducedMotion,
    );
  }

  Future<void> retryBootstrap() async {
    state = state.copyWith(bootstrapFailed: false);
    await ref.read(hasAuthSnapshotProvider.notifier).refreshFromDisk();
  }

  void disposeAnim() {
    _releaseAnim();
    _initializing = false;
  }
}
