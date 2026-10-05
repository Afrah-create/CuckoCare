import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../core/error/result.dart';
import '../domain/vet_case_workflow.dart';
import 'vet_inbox_providers.dart';

Future<void> applyVetCaseAction({
  required BuildContext context,
  required WidgetRef ref,
  required String requestId,
  required VetCaseAction action,
  bool popAfterSuccess = false,
}) async {
  final result = await ref.read(vetInboxRepositoryProvider).setRequestStatus(
        requestId: requestId,
        status: vetStatusAfterAction(action),
      );
  if (!context.mounted) {
    return;
  }
  switch (result) {
    case Success():
      ref.invalidate(vetInboxProvider);
      ref.invalidate(vetMapProvider);
      final message = switch (action) {
        VetCaseAction.accept => 'Request accepted — open Active to start the visit.',
        VetCaseAction.startVisit => 'Visit started.',
        VetCaseAction.markComplete => 'Case marked complete.',
        VetCaseAction.decline => 'Request declined.',
      };
      if (popAfterSuccess) {
        context.pop();
      }
      AppSnack.success(context, message);
    case Error(failure: final f):
      AppSnack.error(context, f.message);
  }
}
