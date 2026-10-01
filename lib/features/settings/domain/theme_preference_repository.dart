import 'package:flutter/material.dart';

abstract interface class ThemePreferenceRepository {
  Future<ThemeMode> load();

  Future<void> save(ThemeMode mode);
}
