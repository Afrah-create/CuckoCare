import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flutter_local_notifications only imported under data_platform/notifications', () {
    final violations = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      if (entity.path.contains('/data_platform/notifications/')) {
        continue;
      }
      final content = entity.readAsStringSync();
      if (content.contains("import 'package:flutter_local_notifications") ||
          content.contains('import "package:flutter_local_notifications')) {
        violations.add(entity.path);
      }
    }
    expect(violations, isEmpty);
  });

  test('manifest has no exact alarm permissions', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest.contains('SCHEDULE_EXACT_ALARM'), isFalse);
    expect(manifest.contains('USE_EXACT_ALARM'), isFalse);
  });
}
