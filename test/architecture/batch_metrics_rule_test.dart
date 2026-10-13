import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Live counts come from BatchMetrics only, so every screen agrees.
void main() {
  test('only batch_metrics.dart subtracts from initialCount', () {
    final pattern = RegExp(r'initialCount\s*-(?!>)|-\s*\w*\.?initialCount\b');
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File ||
          !file.path.endsWith('.dart') ||
          file.path.endsWith('.g.dart') ||
          file.path.endsWith('batch_metrics.dart')) {
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) {
          offenders.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
