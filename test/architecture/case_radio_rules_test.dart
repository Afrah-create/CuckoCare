import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unread counts are derived only in MessageMetrics', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      if (file.path.endsWith('message_metrics.dart')) continue;
      final text = file.readAsStringSync()
          .replaceAll('_metrics.unreadForCase', '')
          .replaceAll('metrics.unreadForCase', '');
      if (text.contains('unreadForCase(')) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('Realtime service never imports Drift write types', () {
    final file = File(
      'lib/features/messaging/data/message_realtime_service.dart',
    );
    final text = file.readAsStringSync();
    expect(text.contains('app_database.dart'), isFalse);
    expect(text.contains('package:drift'), isFalse);
    expect(text.contains('into('), isFalse);
  });

  test('push and SMS builders never include message bodies', () {
    final files = [
      'lib/data_platform/notifications/case_message_push_builder.dart',
      'supabase/functions/notify-case-message/index.ts',
      'supabase/functions/sms-dispatch/index.ts',
    ];
    for (final path in files) {
      final text = File(path).readAsStringSync();
      expect(text.contains('message.body'), isFalse, reason: path);
      expect(text.contains('p_body'), isFalse, reason: path);
    }
  });

  test('messaging domain has no DateTime.now or Flutter imports', () {
    final dir = Directory('lib/features/messaging/domain');
    for (final file in dir.listSync().whereType<File>()) {
      final text = file.readAsStringSync();
      expect(text.contains('DateTime.now()'), isFalse, reason: file.path);
      expect(text.contains("package:flutter/"), isFalse, reason: file.path);
      expect(text.contains('package:drift'), isFalse, reason: file.path);
    }
  });
}
