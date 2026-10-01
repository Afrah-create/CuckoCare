import 'package:flutter/services.dart';

/// Applied once in [bootstrap] — do not lock to portrait.
const kSupportedOrientations = <DeviceOrientation>[
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
];
