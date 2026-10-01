import 'dart:io';

import 'package:cucocare/app/theme/brand_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

String _hex(Color c) {
  final v = c.toARGB32() & 0xFFFFFF;
  return '#${v.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

void main() {
  test('flutter_native_splash.yaml matches BrandTokens splash colours', () {
    final yaml = File('flutter_native_splash.yaml').readAsStringSync();
    final light = _hex(BrandPalette.splashLight);
    final dark = _hex(BrandPalette.splashDark);

    expect(yaml, contains('color: "$light"'));
    expect(yaml, contains('color_dark: "$dark"'));
  });
}
