import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('feed architecture rules', () {
    /// Collects all .dart files under lib/features/feed/ (excluding .g.dart).
    Iterable<File> feedFiles() {
      return Directory('lib/features/feed')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'));
    }

    test('no "usage" kind string in lib/features/feed/ outside fromStorage fallback',
        () {
      // The only acceptable context for the legacy "usage" string is inside
      // the fromStorage switch statement as a fallback or migration comment.
      final offenders = <String>[];
      for (final file in feedFiles()) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          // Allow occurrences inside fromStorage (for migration/fallback comments)
          // but disallow any other literal 'usage' kind usage in the feature code.
          if (line.contains("'usage'") && !line.contains('fromStorage')) {
            offenders.add('${file.path}:${i + 1}: ${line.trim()}');
          }
        }
      }
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });

    test(
        'no direct FeedTransactionKind.isPositive call outside feed_models.dart',
        () {
      final offenders = <String>[];
      for (final file in feedFiles()) {
        if (file.path.endsWith('feed_models.dart')) {
          continue;
        }
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          // Allow suppression comments; flag bare calls
          if (line.contains('.isPositive') &&
              !line.contains('// ignore') &&
              !line.contains('deprecated_member_use')) {
            offenders.add('${file.path}:${i + 1}: ${line.trim()}');
          }
        }
      }
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });

    test(
        'stock arithmetic only in FeedMetrics.compute and feed_repository.dart',
        () {
      // Signs like "qty +=" or "qty -=" (stock accumulation) must not appear
      // in presentation or domain files other than the allowed ones.
      final allowList = {
        'feed_models.dart', // FeedMetrics.compute lives here
        'feed_repository.dart', // _computeStockRows helper
      };
      final pattern = RegExp(r'\bqty\s*[+\-]=');
      final offenders = <String>[];
      for (final file in feedFiles()) {
        final filename = file.path.split('/').last;
        if (allowList.contains(filename)) {
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
  });
}
