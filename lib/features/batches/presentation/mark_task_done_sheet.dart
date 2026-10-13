import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/widgets/states/app_haptics.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../app/widgets/states/progress_button.dart';
import '../../../core/error/user_messages.dart';
import '../../../data_platform/db/app_database.dart';
import '../../notifications/presentation/notification_prefs_provider.dart';

Future<void> showMarkTaskDoneSheet(
  BuildContext context,
  WidgetRef ref, {
  required VaccinationTaskRow task,
  required DateTime today,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return _MarkDoneSheet(task: task, today: today);
    },
  );
}

class _MarkDoneSheet extends ConsumerStatefulWidget {
  const _MarkDoneSheet({required this.task, required this.today});

  final VaccinationTaskRow task;
  final DateTime today;

  @override
  ConsumerState<_MarkDoneSheet> createState() => _MarkDoneSheetState();
}

class _MarkDoneSheetState extends ConsumerState<_MarkDoneSheet> {
  final _product = TextEditingController();

  @override
  void dispose() {
    _product.dispose();
    super.dispose();
  }

  Future<bool> _save() async {
    final doneOn = DateTime.utc(
      widget.today.year,
      widget.today.month,
      widget.today.day,
    );
    try {
      await ref
          .read(batchRepositoryProvider)
          .markTaskDone(
            taskId: widget.task.id,
            todayLocal: widget.today,
            doneOn: doneOn,
            productUsed: _product.text.trim().isEmpty
                ? null
                : _product.text.trim(),
          );
      ref.read(reminderReconcilerProvider).scheduleReconcile();
      AppHaptics.success();
      return true;
    } on StateError catch (error) {
      if (mounted) {
        AppSnack.error(context, error.message);
      }
      return false;
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, userMessageForError(error));
      }
      return false;
    }
  }

  void _afterSave() {
    final repo = ref.read(batchRepositoryProvider);
    final reconcile = ref.read(reminderReconcilerProvider);
    final task = widget.task;
    AppSnack.undo(
      context,
      message: 'Marked done',
      onUndo: () async {
        await repo.revertTaskDone(
          taskId: task.id,
          previousStatus: task.status,
          previousDoneOn: task.doneOn,
          previousProduct: task.productUsed,
        );
        reconcile.scheduleReconcile();
      },
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
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
          Text('Mark done', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text('Date: ${DateFormat.yMMMd().format(widget.today)}'),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _product,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Product used (optional)',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ProgressButton(
            label: 'Mark done',
            busyLabel: 'Saving…',
            onPressed: _save,
            onSuccess: _afterSave,
          ),
        ],
      ),
    );
  }
}
