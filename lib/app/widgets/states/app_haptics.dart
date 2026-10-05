import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppHaptics {
  static bool enabled = true;

  static void selection() {
    if (!enabled) {
      return;
    }
    HapticFeedback.selectionClick();
  }

  static void success() {
    if (!enabled) {
      return;
    }
    HapticFeedback.lightImpact();
  }

  static void warning() {
    if (!enabled) {
      return;
    }
    HapticFeedback.mediumImpact();
  }

  static void error() {
    if (!enabled) {
      return;
    }
    HapticFeedback.vibrate();
  }
}

const hapticPreferenceKey = 'haptic_feedback';

final hapticFeedbackProvider = NotifierProvider<HapticFeedbackNotifier, bool>(
  HapticFeedbackNotifier.new,
);

class HapticFeedbackNotifier extends Notifier<bool> {
  @override
  bool build() {
    AppHaptics.enabled = true;
    _load();
    return true;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getBool(hapticPreferenceKey);
      if (stored == null) {
        return;
      }
      state = stored;
      AppHaptics.enabled = stored;
    } catch (_) {
      // Keep the default.
    }
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    AppHaptics.enabled = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(hapticPreferenceKey, value);
    } catch (_) {
      // The in-memory choice still applies this session.
    }
  }
}
