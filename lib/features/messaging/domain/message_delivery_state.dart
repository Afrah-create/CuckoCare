enum MessageDeliveryKind { queued, sending, sent, seen, failed }

class MessageDeliveryState {
  const MessageDeliveryState(this.kind, {this.reason});

  final MessageDeliveryKind kind;
  final String? reason;

  static MessageDeliveryState derive({
    required bool inOutbox,
    required bool inFlight,
    required bool failed,
    required String? failReason,
    required bool hasServerVersion,
    required bool seenByOther,
  }) {
    if (failed) {
      return MessageDeliveryState(
        MessageDeliveryKind.failed,
        reason: failReason,
      );
    }
    if (inFlight) return const MessageDeliveryState(MessageDeliveryKind.sending);
    if (inOutbox) return const MessageDeliveryState(MessageDeliveryKind.queued);
    if (seenByOther) return const MessageDeliveryState(MessageDeliveryKind.seen);
    if (hasServerVersion) {
      return const MessageDeliveryState(MessageDeliveryKind.sent);
    }
    return const MessageDeliveryState(MessageDeliveryKind.queued);
  }
}

enum AttachmentSubState {
  waitingForSignal,
  uploading,
  uploaded,
  failed,
}
