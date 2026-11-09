/// Gating, validation, and failure reasons for Case Radio.
class MessagingRules {
  const MessagingRules();

  static const maxBodyLength = 1000;
  static const warnBodyLength = 900;
  static const maxPhotosPerMessage = 3;
  static const maxThumbBytes = 8192;
  static const maxAttachmentBytes = 1024 * 1024;
  static const ratePerWindow = 30;
  static const rateWindowMinutes = 10;
  static const ratePerDay = 300;

  static const sendingRoles = {'owner', 'manager', 'worker'};

  bool canSend({
    required String requestStatus,
    required String farmRole,
    required bool isAssignedVet,
    required bool requestDeleted,
  }) {
    if (requestDeleted) return false;
    if (!isOpen(requestStatus)) return false;
    if (isAssignedVet) return true;
    return sendingRoles.contains(farmRole);
  }

  bool canRead({
    required String farmRole,
    required bool isAssignedVet,
    required bool isFarmMember,
  }) {
    if (isAssignedVet) return true;
    return isFarmMember;
  }

  bool isOpen(String status) =>
      status == 'accepted' || status == 'in_progress';

  bool isArchived(String status) =>
      status == 'completed' ||
      status == 'cancelled' ||
      status == 'declined';

  bool isWaitingForAcceptance(String status) =>
      status == 'submitted' ||
      status == 'received' ||
      status == 'draft' ||
      status == 'pending_sync';

  String? validateText(String raw) {
    final body = raw.trim();
    if (body.isEmpty) return 'empty';
    if (body.length > maxBodyLength) return 'too_long';
    return null;
  }

  String composerDisabledReason({
    required String requestStatus,
    required bool isViewer,
  }) {
    if (isViewer) {
      return 'Viewers can read this thread but cannot send.';
    }
    if (isWaitingForAcceptance(requestStatus)) {
      return 'You can message the vet once they accept your request. Waiting for acceptance.';
    }
    if (isArchived(requestStatus)) {
      return 'This case is closed. You can still read the thread.';
    }
    return 'Messaging is not available for this request.';
  }

  String mapSyncFailure(String? errorCode) {
    return switch (errorCode) {
      'P0001' || 'case_closed' => 'Failed: this case is closed',
      'P0002' || 'rate_limited' => 'Too many messages. Try again later.',
      '42501' || 'forbidden' => 'You cannot send on this case.',
      '22023' || 'too_large' => 'That photo is too large.',
      _ => 'Could not send. Saved on this phone.',
    };
  }
}
