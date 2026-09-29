import 'package:cucocare/features/home/presentation/home_shell.dart';
import 'package:cucocare/data_platform/sync/sync_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SyncStatusChip renders offline state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SyncStatusChip(
            status: SyncStatus(
              phase: SyncPhase.offline,
              pendingOutboxCount: 2,
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('Offline'), findsOneWidget);
    expect(find.textContaining('2'), findsOneWidget);
  });
}
