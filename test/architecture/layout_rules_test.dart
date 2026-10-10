import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final features = Directory('lib/features');

  test('feature screens use AppPage or AuthShell and no raw scaffold', () {
    final screens = features
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('_screen.dart'))
        .toList();

    expect(screens, isNotEmpty);
    final problems = <String>[];
    for (final file in screens) {
      final source = file.readAsStringSync();
      final usesPage = source.contains('AppPage') || source.contains('AuthShell');
      if (!usesPage) {
        problems.add('${file.path} does not use AppPage or AuthShell');
      }
      if (source.contains('Scaffold(')) {
        problems.add('${file.path} builds its own Scaffold');
      }
      if (source.contains('MediaQuery.of(context).size') ||
          source.contains('MediaQuery.sizeOf') ||
          source.contains('OrientationBuilder') ||
          source.contains('Orientation.landscape')) {
        problems.add('${file.path} reads raw window size or orientation');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));

    final raw = <String>[];
    for (final entity in features.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final source = entity.readAsStringSync();
      if (source.contains('MediaQuery.of(context).size') ||
          source.contains('MediaQuery.sizeOf') ||
          source.contains('OrientationBuilder') ||
          source.contains('Orientation.landscape') ||
          source.contains('Scaffold(')) {
        raw.add(entity.path);
      }
    }
    expect(raw, isEmpty, reason: raw.join('\n'));
  });

  test('screen-size constants stay in breakpoints.dart', () {
    final hits = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      if (entity.path.endsWith('breakpoints.dart')) {
        continue;
      }
      final source = entity.readAsStringSync();
      for (final token in ['360', '600', '840']) {
        if (RegExp('\\b$token\\b').hasMatch(source) &&
            source.contains('Breakpoints') == false &&
            _looksLikeBreakpoint(source, token)) {
          hits.add('${entity.path} uses $token as a layout breakpoint');
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });
}

bool _looksLikeBreakpoint(String source, String token) {
  return source.contains('width >= $token') ||
      source.contains('width > $token') ||
      source.contains('height < $token') ||
      source.contains('size.width >= $token');
}
