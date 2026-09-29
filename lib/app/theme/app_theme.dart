import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const seed = Color(0xFF2E7D32);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed),
    useMaterial3: true,
  );
}
