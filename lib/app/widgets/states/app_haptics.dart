import 'package:flutter/services.dart';

abstract class AppHaptics {
  static void selection() => HapticFeedback.selectionClick();

  static void success() => HapticFeedback.lightImpact();

  static void warning() => HapticFeedback.mediumImpact();

  static void error() => HapticFeedback.vibrate();
}
