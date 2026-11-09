import 'message_delivery_state.dart';

class CaseThreadMessage {
  const CaseThreadMessage({
    required this.id,
    required this.requestId,
    required this.senderUserId,
    required this.senderRole,
    required this.kind,
    required this.body,
    required this.clientCreatedAt,
    required this.createdAt,
    required this.delivery,
    this.serverVersion,
    this.attachments = const [],
  });

  final String id;
  final String requestId;
  final String? senderUserId;
  final String senderRole;
  final String kind;
  final String? body;
  final DateTime clientCreatedAt;
  final DateTime createdAt;
  final int? serverVersion;
  final MessageDeliveryState delivery;
  final List<CaseThreadAttachment> attachments;

  bool get isPending => serverVersion == null;
  bool get isMine => senderRole != 'system';
}

class CaseThreadAttachment {
  const CaseThreadAttachment({
    required this.id,
    required this.objectKey,
    required this.status,
    this.bytes,
    this.thumbB64,
    this.subState = AttachmentSubState.uploaded,
  });

  final String id;
  final String objectKey;
  final String status;
  final int? bytes;
  final String? thumbB64;
  final AttachmentSubState subState;
}

class CaseThread {
  const CaseThread({required this.messages});

  final List<CaseThreadMessage> messages;

  /// Server order, then pending outbox messages at the bottom.
  static List<CaseThreadMessage> order(List<CaseThreadMessage> input) {
    final acked = input.where((m) => !m.isPending).toList()
      ..sort((a, b) {
        final byTime = a.createdAt.compareTo(b.createdAt);
        if (byTime != 0) return byTime;
        return a.id.compareTo(b.id);
      });
    final pending = input.where((m) => m.isPending).toList()
      ..sort((a, b) => a.clientCreatedAt.compareTo(b.clientCreatedAt));
    return [...acked, ...pending];
  }

  /// First index of a message from the other party after [lastReadAt].
  static int? newMessagesDividerIndex({
    required List<CaseThreadMessage> ordered,
    required DateTime? lastReadAt,
    required String myUserId,
  }) {
    if (lastReadAt == null) {
      final i = ordered.indexWhere(
        (m) => m.senderRole != 'system' && m.senderUserId != myUserId,
      );
      return i < 0 ? null : i;
    }
    final i = ordered.indexWhere(
      (m) =>
          m.senderRole != 'system' &&
          m.senderUserId != myUserId &&
          m.createdAt.isAfter(lastReadAt),
    );
    return i < 0 ? null : i;
  }

  static String timeLabel(CaseThreadMessage m) {
    final written = m.clientCreatedAt.toLocal();
    final sent = m.createdAt.toLocal();
    final sameMinute = written.year == sent.year &&
        written.month == sent.month &&
        written.day == sent.day &&
        written.hour == sent.hour &&
        written.minute == sent.minute;
    if (sameMinute || m.isPending) {
      return _hm(written);
    }
    return 'Written ${_hm(written)} · Sent ${_hm(sent)}';
  }

  static String _hm(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
