import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feature code avoids hard-coded colours and brightness branching', () {
    final allowlist = <String>{};
    final allowFile = File('test/architecture/theme_rules_allowlist.txt');
    if (allowFile.existsSync()) {
      for (final line in allowFile.readAsLinesSync()) {
        final t = line.trim();
        if (t.isEmpty || t.startsWith('#')) {
          continue;
        }
        allowlist.add(t);
      }
    }

    final violations = <String>[];
    final lib = Directory('lib');
    for (final entity in lib.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      if (entity.path.contains('/app/theme/')) {
        continue;
      }
      final isSettings = entity.path.contains('/features/settings/');
      if (entity.path.endsWith('.g.dart') ||
          entity.path.endsWith('.freezed.dart')) {
        continue;
      }

      final rel = entity.path.replaceFirst('lib/', 'lib/');
      final content = entity.readAsStringSync();
      final lines = content.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final loc = '${entity.path}:${i + 1}';
        if (allowlist.contains(loc)) {
          continue;
        }

        if (line.contains('Color(0x') || line.contains('Colors.')) {
          violations.add('$loc hard-coded colour');
        }
        if (!isSettings &&
            (line.contains('platformBrightness') ||
                line.contains('.brightness ==') ||
                line.contains('isDark'))) {
          violations.add('$loc brightness branch');
        }
        if (line.contains('ThemeMode.') &&
            !isSettings &&
            entity.path != 'lib/app/app.dart' &&
            entity.path != 'lib/main.dart') {
          violations.add('$loc ThemeMode reference');
        }
        if (line.contains('TextStyle(') &&
            (line.contains('color:') || line.contains('fontSize:'))) {
          violations.add('$loc raw TextStyle');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
