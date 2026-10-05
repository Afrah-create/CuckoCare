import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_motion.dart';
import '../inline_banner.dart';
import 'offline_notice.dart';
import 'state_simulator.dart';

/// The only way a screen paints an [AsyncValue].
///
/// Fast loads stay blank. Slow loads show [skeleton] for at least
/// [AppMotion.skeletonMinVisible], then cross-fade to content.
class AsyncStateView<T> extends StatefulWidget {
  const AsyncStateView({
    required this.value,
    required this.builder,
    required this.skeleton,
    this.isEmpty,
    this.empty,
    this.error,
    this.onRetry,
    this.loadTimeout = AppMotion.loadTimeout,
    this.screenId,
    this.expand = true,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final Widget skeleton;
  final bool Function(T data)? isEmpty;
  final Widget? empty;
  final Widget Function(Object error, StackTrace stack)? error;
  final VoidCallback? onRetry;
  final Duration loadTimeout;
  final String? screenId;
  final bool expand;

  @override
  State<AsyncStateView<T>> createState() => _AsyncStateViewState<T>();
}

class _AsyncStateViewState<T> extends State<AsyncStateView<T>> {
  Timer? _revealTimer;
  Timer? _holdTimer;
  Timer? _timeoutTimer;
  Timer? _slowTimer;
  DateTime? _slowUntil;
  var _skeletonOn = false;
  var _timedOut = false;
  var _releaseScheduled = false;

  bool get _firstLoad => widget.value.isLoading && !widget.value.hasValue;

  SimulatedLoad? _forced() {
    final id = widget.screenId;
    if (id == null) {
      return null;
    }
    return StateSimulatorScope.maybeOf(context)?.forcedFor(id);
  }

  bool get _slow => StateSimulatorScope.maybeOf(context)?.slowNetwork ?? false;

  bool get _holdingSlow =>
      _slow && _slowUntil != null && DateTime.now().isBefore(_slowUntil!);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant AsyncStateView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _holdTimer?.cancel();
    _timeoutTimer?.cancel();
    _slowTimer?.cancel();
    super.dispose();
  }

  void _sync() {
    final motion = AppMotion.of(context);
    final forcedLoading = _forced() == SimulatedLoad.loading;

    if (_slow && _slowUntil == null && (forcedLoading || _firstLoad || widget.value.hasValue)) {
      _slowUntil = DateTime.now().add(AppMotion.slowNetwork);
      _slowTimer?.cancel();
      _slowTimer = Timer(AppMotion.slowNetwork, () {
        if (!mounted) {
          return;
        }
        setState(() {});
        _sync();
      });
    }

    final waiting = _firstLoad || forcedLoading || _holdingSlow;

    if (!waiting) {
      _revealTimer?.cancel();
      _revealTimer = null;
      _timeoutTimer?.cancel();
      _timeoutTimer = null;
      if (_timedOut) {
        _timedOut = false;
      }
      if (_skeletonOn) {
        _releaseWhenReady(motion.skeletonMinVisible);
      }
      return;
    }

    _holdTimer?.cancel();
    _holdTimer = null;
    _releaseScheduled = false;
    _timeoutTimer ??= Timer(widget.loadTimeout, () {
      if (!mounted) {
        return;
      }
      if (_firstLoad || _forced() == SimulatedLoad.loading) {
        setState(() => _timedOut = true);
      }
    });

    if (_skeletonOn || _revealTimer != null) {
      return;
    }

    final delay = motion.skeletonDelay;
    if (delay == Duration.zero) {
      _armSkeleton();
      return;
    }
    _revealTimer = Timer(delay, () {
      _revealTimer = null;
      if (!mounted) {
        return;
      }
      if (_firstLoad || _forced() == SimulatedLoad.loading || _holdingSlow) {
        _armSkeleton();
      }
    });
  }

  void _armSkeleton() {
    setState(() => _skeletonOn = true);
  }

  void _releaseWhenReady(Duration minimum) {
    if (_releaseScheduled) {
      return;
    }
    _releaseScheduled = true;
    if (minimum <= Duration.zero) {
      if (_skeletonOn) {
        setState(() => _skeletonOn = false);
      }
      return;
    }
    _holdTimer?.cancel();
    _holdTimer = Timer(minimum, () {
      if (!mounted || _firstLoad) {
        return;
      }
      setState(() => _skeletonOn = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);
    final forced = _forced();
    final refreshing = widget.value.isLoading &&
        widget.value.hasValue &&
        !_skeletonOn &&
        !_holdingSlow &&
        forced != SimulatedLoad.loading;

    final page = _page(forced);
    final faded = AnimatedSwitcher(
      duration: motion.standard,
      switchInCurve: motion.curveStandard,
      switchOutCurve: motion.curveStandard,
      layoutBuilder: (current, previous) => current ?? const SizedBox.shrink(),
      child: KeyedSubtree(
        key: ValueKey(page.$1),
        child: page.$2,
      ),
    );

    return Stack(
      fit: widget.expand ? StackFit.expand : StackFit.passthrough,
      children: [
        faded,
        if (refreshing)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  (String, Widget) _page(SimulatedLoad? forced) {
    if (forced == SimulatedLoad.error || (_timedOut && !widget.value.hasValue)) {
      final error = _timedOut ? LoadTimedOut() : (widget.value.error ?? LoadTimedOut());
      final stack = widget.value.stackTrace ?? StackTrace.empty;
      return ('error', _error(error, stack));
    }

    if (forced == SimulatedLoad.empty) {
      return ('empty', widget.empty ?? const SizedBox.shrink());
    }

    if (_skeletonOn) {
      return ('skeleton', widget.skeleton);
    }

    if (widget.value.hasError && !widget.value.hasValue) {
      return (
        'error',
        _error(widget.value.error!, widget.value.stackTrace ?? StackTrace.empty),
      );
    }

    if (!widget.value.hasValue) {
      return ('blank', const SizedBox.shrink());
    }

    final data = widget.value.requireValue;
    final empty = widget.isEmpty?.call(data) ?? false;
    if (empty || forced == SimulatedLoad.empty) {
      return ('empty', widget.empty ?? widget.builder(data));
    }

    var content = widget.builder(data);
    final stale = widget.value.hasError && widget.value.hasValue;
    final offline = forced == SimulatedLoad.offline;
    if (stale || offline) {
      content = Column(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (offline)
            const OfflineNotice()
          else
            const InlineBanner(
              message: "Couldn't update. Showing saved data.",
              icon: Icons.cloud_off_outlined,
              tone: BannerTone.warning,
            ),
          if (widget.expand) Expanded(child: content) else content,
        ],
      );
    }
    return ('data', content);
  }

  Widget _error(Object error, StackTrace stack) {
    return widget.error?.call(error, stack) ??
        const Center(child: Text('Something went wrong. Please try again.'));
  }
}

class LoadTimedOut implements Exception {
  @override
  String toString() => 'LoadTimedOut';
}
