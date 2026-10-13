import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/widgets/states/app_dialog.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data_platform/db/app_database.dart';
import '../../notifications/presentation/notification_prefs_provider.dart';
import 'batch_providers.dart';
import 'close_batch_sheet.dart';
import 'loss_form_screen.dart';

const savedMessage = 'Saved on this phone';
const saveErrorMessage = "Couldn't save. Please try again.";

/// Rule, permission and not-found failures carry their own copy; anything
/// else gets the standard save error.
String failureText(Failure failure) => switch (failure) {
  ValidationFailure(:final message) ||
  NotFoundFailure(:final message) ||
  PermissionFailure(:final message) => message,
  _ => saveErrorMessage,
};

String _plural(int n, String one, String many) =>
    n == 1 ? '1 $one' : '$n $many';

/// Queues sync and refreshes reminders after any batch or loss write.
void Function() afterBatchWrite(WidgetRef ref) {
  final scheduler = ref.read(syncSchedulerProvider);
  final reconciler = ref.read(reminderReconcilerProvider);
  return () {
    scheduler.notifyLocalWrite();
    reconciler.scheduleReconcile();
  };
}

/// Opens the record-loss form and shows the result from this screen.
Future<void> openRecordLoss(
  BuildContext context,
  WidgetRef ref,
  String batchId,
) async {
  final result = await LossNewRoute(batchId: batchId)
      .push<LossFormResult>(context);
  if (result == null || !context.mounted) {
    return;
  }
  ref.read(highlightedLossProvider.notifier).mark(result.lossId);
  final management = ref.read(batchManagementProvider);
  final afterWrite = afterBatchWrite(ref);
  AppSnack.undo(
    context,
    message: savedMessage,
    onUndo: () async {
      final undo = await management.deleteLoss(result.lossId);
      if (undo.isSuccess) {
        afterWrite();
      }
    },
  );
}

Future<void> openEditLoss(
  BuildContext context,
  WidgetRef ref, {
  required String batchId,
  required String lossId,
}) async {
  final result = await LossEditRoute(
    batchId: batchId,
    lossId: lossId,
  ).push<LossFormResult>(context);
  if (result == null || !context.mounted) {
    return;
  }
  ref.read(highlightedLossProvider.notifier).mark(result.lossId);
  AppSnack.success(context, savedMessage);
}

Future<void> deleteLoss(
  BuildContext context,
  WidgetRef ref,
  String lossId,
) async {
  final management = ref.read(batchManagementProvider);
  final afterWrite = afterBatchWrite(ref);
  final result = await management.deleteLoss(lossId);
  if (!context.mounted) {
    return;
  }
  switch (result) {
    case Success():
      afterWrite();
      AppSnack.undo(
        context,
        message: 'Loss record deleted',
        onUndo: () async {
          final undo = await management.restoreLoss(lossId);
          if (undo.isSuccess) {
            afterWrite();
          }
        },
      );
    case Error(:final failure):
      AppSnack.error(context, failureText(failure));
  }
}

/// Returns true when the batch was deleted, so a detail screen can pop.
Future<bool> confirmDeleteBatch(
  BuildContext context,
  WidgetRef ref,
  BatchRow batch,
) async {
  final counts = await ref
      .read(batchRepositoryProvider)
      .cascadeCounts(batch.id);
  if (!context.mounted) {
    return false;
  }
  final confirmed = await showConfirmDialog(
    context: context,
    title: 'Delete ${batch.name}?',
    message:
        'This removes the batch, its ${_plural(counts.tasks, 'task', 'tasks')} '
        'and ${_plural(counts.losses, 'loss record', 'loss records')} from your lists. '
        'Feed and vet records stay.\n\n'
        'Finished with this batch? Close it instead to keep its history.',
    confirmLabel: 'Delete batch',
    destructive: true,
  );
  if (confirmed != true || !context.mounted) {
    return false;
  }
  final management = ref.read(batchManagementProvider);
  final afterWrite = afterBatchWrite(ref);
  final result = await management.deleteBatch(batch.id);
  if (!context.mounted) {
    return result.isSuccess;
  }
  switch (result) {
    case Success(:final value):
      afterWrite();
      AppSnack.undo(
        context,
        message: 'Batch deleted',
        onUndo: () async {
          final undo = await management.restoreBatch(value.groupId);
          if (undo.isSuccess) {
            afterWrite();
          }
        },
      );
      return true;
    case Error(:final failure):
      AppSnack.error(context, failureText(failure));
      return false;
  }
}

Future<void> closeBatch(
  BuildContext context,
  WidgetRef ref,
  BatchRow batch,
) async {
  final closed = await showCloseBatchSheet(context, batch: batch);
  if (closed != true || !context.mounted) {
    return;
  }
  final management = ref.read(batchManagementProvider);
  final afterWrite = afterBatchWrite(ref);
  afterWrite();
  AppSnack.undo(
    context,
    message: savedMessage,
    onUndo: () async {
      final undo = await management.reopenBatch(batch.id);
      if (undo.isSuccess) {
        afterWrite();
      }
    },
  );
}

Future<void> reopenBatch(
  BuildContext context,
  WidgetRef ref,
  BatchRow batch,
) async {
  final confirmed = await showConfirmDialog(
    context: context,
    title: 'Reopen ${batch.name}?',
    message: 'Reminders for pending tasks will resume.',
    confirmLabel: 'Reopen batch',
  );
  if (confirmed != true || !context.mounted) {
    return;
  }
  final afterWrite = afterBatchWrite(ref);
  final result = await ref.read(batchManagementProvider).reopenBatch(batch.id);
  if (!context.mounted) {
    return;
  }
  switch (result) {
    case Success():
      afterWrite();
      AppSnack.success(context, savedMessage);
    case Error(:final failure):
      AppSnack.error(context, failureText(failure));
  }
}

Future<void> openEditBatch(BuildContext context, String batchId) async {
  final saved = await BatchEditRoute(batchId: batchId).push<bool>(context);
  if (saved == true && context.mounted) {
    AppSnack.success(context, savedMessage);
  }
}
