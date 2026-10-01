import 'dart:async';

import 'package:flutter/material.dart';

/// Types an example hint once per focus session (respects reduced motion).
class TypedHintController {
  TypedHintController({
    required this.fullText,
    this.charMs = 35,
    this.onUpdate,
  });

  final String fullText;
  final int charMs;
  final VoidCallback? onUpdate;

  String _visible = '';
  Timer? _timer;
  bool _playedThisFocus = false;

  String get visible => _visible;

  void onFocus(bool hasFocus, {required bool reduceMotion}) {
    if (!hasFocus) {
      _timer?.cancel();
      _visible = '';
      _playedThisFocus = false;
      return;
    }
    if (_playedThisFocus || fullText.isEmpty) {
      return;
    }
    _playedThisFocus = true;
    if (reduceMotion) {
      _visible = fullText;
      onUpdate?.call();
      return;
    }
    _visible = '';
    var i = 0;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: charMs), (t) {
      i++;
      if (i > fullText.length) {
        t.cancel();
        return;
      }
      _visible = fullText.substring(0, i);
      onUpdate?.call();
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}
