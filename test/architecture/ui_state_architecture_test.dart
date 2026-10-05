import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feature screens use the shared state widgets', () {
    final root = Directory('lib/features');
    final files = root
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    final problems = <String>[];
    for (final file in files) {
      final text = file.readAsStringSync();
      final path = file.path;
      void forbid(String needle) {
        if (text.contains(needle)) {
          problems.add('$path contains $needle');
        }
      }

      forbid('CircularProgressIndicator');
      forbid('LinearProgressIndicator');
      forbid('showSnackBar');
      forbid('SnackBar(');
      forbid('AlertDialog(');
      forbid('showDialog(');

      if (path.endsWith('_screen.dart')) {
        forbid('.when(');
      }
    }

    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}
