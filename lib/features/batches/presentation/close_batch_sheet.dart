import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/app_haptics.dart';
import '../../../app/widgets/states/progress_button.dart';
import '../../../core/error/result.dart';
import '../../../data_platform/db/app_database.dart';
import '../data/batch_views.dart';
import '../domain/batch_facts.dart';
import '../domain/calendar_date.dart';
import 'batch_actions.dart';
import 'batch_labels.dart';
import 'batch_providers.dart';
import 'date_choice.dart';

/// Returns true once the batch is closed.
Future<bool?> showCloseBatchSheet(
  BuildContext context, {
  required BatchRow batch,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => _CloseBatchSheet(batch: batch),
  );
}

class _CloseBatchSheet extends ConsumerStatefulWidget {
  const _CloseBatchSheet({required this.batch});

  final BatchRow batch;

  @override
  ConsumerState<_CloseBatchSheet> createState() => _CloseBatchSheetState();
}

class _CloseBatchSheetState extends ConsumerState<_CloseBatchSheet> {
  final _note = TextEditingController();
  CalendarDate? _closedOn;
  CloseReason? _reason;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<bool> _save() async {
    final today = ref.read(todayDateProvider);
    final result = await ref
        .read(batchManagementProvider)
        .closeBatch(
          batchId: widget.batch.id,
          closedOn: _closedOn ?? today,
          reason: _reason,
          note: _note.text,
        );
    if (!mounted) {
      return false;
    }
    switch (result) {
      case Success():
        AppHaptics.success();
        return true;
      case Error(:final failure):
        setState(() => _error = failureText(failure));
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayDateProvider);
    final facts = batchFactsFromRow(widget.batch);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Close batch', style: context.text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Closing keeps the batch and its history. Its reminders stop, and '
            'you can reopen it later.',
            style: context.text.bodyMedium?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Why are you closing it?', style: context.text.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final reason in CloseReason.values)
                ChoiceChip(
                  label: Text(closeReasonLabel(reason)),
                  selected: _reason == reason,
                  onSelected: (_) => setState(() {
                    _reason = reason;
                    _error = null;
                  }),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Close date', style: context.text.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          DateChoice(
            value: _closedOn ?? today,
            today: today,
            firstDate: facts.acquiredOn,
            onChanged: (day) => setState(() {
              _closedOn = day;
              _error = null;
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _note,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Note (optional)'),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: context.text.bodyMedium?.copyWith(
                color: context.scheme.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          ProgressButton(
            label: 'Close batch',
            busyLabel: 'Closing…',
            onPressed: _save,
            onSuccess: () => context.pop(true),
          ),
        ],
      ),
    );
  }
}
