import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/pending_sync_badge.dart';
import '../domain/loss_record.dart';
import 'batch_actions.dart';
import 'batch_labels.dart';

/// Loss details with Edit and Delete. Closed batches and viewers see no actions.
Future<void> showLossDetailSheet(
  BuildContext context,
  WidgetRef ref, {
  required LossEntry entry,
  required bool readOnly,
  String? batchName,
}) {
  final permissions = ref.read(batchPermissionsProvider);
  final canChange = !readOnly && permissions.canRecordLosses;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final rows = <(String, String)>[
        if (batchName != null) ('Batch', batchName),
        ('Date', formatDay(entry.occurredOn)),
        ('What happened', lossKindLabel(entry.kind)),
        if (entry.suspectedCause != null)
          ('Your guess', causeLabel(entry.suspectedCause!)),
        if (entry.notes != null) ('Notes', entry.notes!),
      ];
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    birdsLabel(entry.count),
                    style: sheetContext.text.titleLarge,
                  ),
                ),
                PendingSyncBadge(rowId: entry.id),
              ],
            ),
            if (entry.isEdited)
              Text(
                'Edited',
                style: sheetContext.text.labelMedium?.copyWith(
                  color: sheetContext.scheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: sheetContext.text.labelMedium?.copyWith(
                        color: sheetContext.scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(value, style: sheetContext.text.bodyLarge),
                  ],
                ),
              ),
            if (canChange) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                      ),
                      onPressed: () {
                        sheetContext.pop();
                        deleteLoss(context, ref, entry.id);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        sheetContext.pop();
                        openEditLoss(
                          context,
                          ref,
                          batchId: entry.batchId,
                          lossId: entry.id,
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    },
  );
}
