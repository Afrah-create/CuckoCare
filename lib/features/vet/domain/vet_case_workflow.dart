/// Vet-side actions on a farmer assistance request.
enum VetCaseAction {
  accept,
  startVisit,
  markComplete,
  decline,
}

/// Next server `status` after a vet action.
String vetStatusAfterAction(VetCaseAction action) {
  return switch (action) {
    VetCaseAction.accept => 'accepted',
    VetCaseAction.startVisit => 'in_progress',
    VetCaseAction.markComplete => 'completed',
    VetCaseAction.decline => 'declined',
  };
}

/// Human-readable status for vets (avoid ambiguous "pending").
String vetRequestStatusLabel(String status) {
  return switch (status) {
    'submitted' => 'New request',
    'received' => 'Received',
    'accepted' => 'Accepted — not started',
    'in_progress' => 'Visit in progress',
    'completed' => 'Completed',
    'declined' => 'Declined',
    'cancelled' => 'Cancelled',
    'draft' => 'Draft',
    _ => status,
  };
}

/// Actions available to the assigned vet for the current status.
List<VetCaseAction> vetCaseActionsFor({
  required String status,
  required bool isAssignedToMe,
}) {
  if (!isAssignedToMe && status != 'submitted' && status != 'received') {
    return const [];
  }
  return switch (status) {
    'submitted' || 'received' => const [
        VetCaseAction.accept,
        VetCaseAction.decline,
      ],
    'accepted' when isAssignedToMe => const [VetCaseAction.startVisit],
    'in_progress' when isAssignedToMe => const [VetCaseAction.markComplete],
    _ => const [],
  };
}

String vetCaseActionLabel(VetCaseAction action) {
  return switch (action) {
    VetCaseAction.accept => 'Accept',
    VetCaseAction.startVisit => 'Start visit',
    VetCaseAction.markComplete => 'Mark complete',
    VetCaseAction.decline => 'Decline',
  };
}
