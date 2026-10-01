import 'package:cucocare/app/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppShell keeps a stable body row key for adaptive chrome', () {
    expect(AppShell.shellBodyKey, const ValueKey<String>('app-shell-body'));
  });
}
