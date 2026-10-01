import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lifecycle and orientation rules', () {
    final violations = <String>[];
    final lib = Directory('lib');

    for (final entity in lib.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      if (entity.path.contains('/core/lifecycle/')) {
        continue;
      }
      final content = entity.readAsStringSync();
      final lines = content.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final loc = '${entity.path}:${i + 1}';
        if (line.contains('WidgetsBindingObserver') ||
            line.contains('AppLifecycleListener(')) {
          violations.add('$loc lifecycle observer outside service');
        }
        if (entity.path.contains('/features/') &&
            line.contains('MediaQuery') &&
            line.contains('initState')) {
          violations.add('$loc MediaQuery in initState');
        }
      }
    }

    for (final entity in ['lib/main.dart', 'lib/bootstrap.dart']) {
      final content = File(entity).readAsStringSync();
      if (content.contains('setPreferredOrientations') &&
          entity == 'lib/main.dart') {
        violations.add('$entity must not set orientations (use bootstrap)');
      }
    }

    if (!File('lib/bootstrap.dart').readAsStringSync().contains(
          'setPreferredOrientations',
        )) {
      violations.add('bootstrap.dart must apply kSupportedOrientations');
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
