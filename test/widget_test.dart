import 'package:cucocare/app/widgets/sync_status_badge.dart';
import 'package:cucocare/data_platform/sync/sync_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SyncStatusBadge renders offline state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SyncStatusBadge(
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
