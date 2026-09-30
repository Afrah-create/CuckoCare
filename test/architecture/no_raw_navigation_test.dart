import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib/features does not use raw Navigator pushes or MaterialPageRoute', () {
    final featuresDir = Directory('lib/features');
    expect(featuresDir.existsSync(), isTrue);

    final violations = <String>[];
    for (final entity in featuresDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      if (entity.path.contains('/features/dev/')) {
        continue;
      }
      final content = entity.readAsStringSync();
      if (content.contains('MaterialPageRoute')) {
        violations.add('${entity.path}: MaterialPageRoute');
      }
      if (content.contains('WillPopScope')) {
        violations.add('${entity.path}: WillPopScope');
      }
      if (RegExp(r'Navigator\.(of|push)').hasMatch(content)) {
        violations.add('${entity.path}: Navigator.of/push');
      }
    }

    expect(
      violations,
      isEmpty,
      reason: violations.join('\n'),
    );
  });
}
