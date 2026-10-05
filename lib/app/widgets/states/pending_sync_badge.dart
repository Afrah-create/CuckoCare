import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/providers.dart';
import '../../theme/theme_context.dart';

final pendingSyncIdsProvider = StreamProvider<Set<String>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.customSelect(
    "SELECT row_id FROM outbox WHERE state IN ('pending', 'in_flight', 'blocked')",
    readsFrom: {db.outbox},
  );
  return query.watch().map(
        (rows) => rows.map((row) => row.read<String>('row_id')).toSet(),
      );
});

class PendingSyncBadge extends ConsumerWidget {
  const PendingSyncBadge({this.rowId, this.pending, super.key});

  final String? rowId;
  final bool? pending;

  static const tooltip = 'Saved on this phone. Will sync when online';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final show = pending ??
        (rowId != null &&
            (ref.watch(pendingSyncIdsProvider).value?.contains(rowId) ??
                false));
    if (!show) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: tooltip,
        child: Icon(
          Icons.cloud_upload_outlined,
          size: 16,
          color: context.colors.pendingSyncIndicator,
        ),
      ),
    );
  }
}
