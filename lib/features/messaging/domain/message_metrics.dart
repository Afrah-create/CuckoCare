import 'case_thread.dart';

class UnreadCaseCount {
  const UnreadCaseCount({required this.requestId, required this.unread});

  final String requestId;
  final int unread;
}

class UnreadThreadHint {
  const UnreadThreadHint({
    required this.requestId,
    required this.farmId,
    required this.status,
    required this.priority,
    required this.unread,
    this.summary,
  });

  final String requestId;
  final String farmId;
  final String status;
  final String priority;
  final int unread;
  final String? summary;
}

/// Single place unread counts are derived (architecture test).
class MessageMetrics {
  const MessageMetrics();

  int unreadForCase({
    required List<CaseThreadMessage> messages,
    required String myUserId,
    required DateTime? lastReadAt,
  }) {
    var n = 0;
    for (final m in messages) {
      if (m.senderRole == 'system') continue;
      if (m.senderUserId == myUserId) continue;
      if (m.serverVersion == null) continue;
      if (lastReadAt == null || m.createdAt.isAfter(lastReadAt)) {
        n++;
      }
    }
    return n;
  }

  List<UnreadCaseCount> grouped({
    required List<CaseThreadMessage> messages,
    required String myUserId,
    required Map<String, DateTime?> lastReadByRequest,
  }) {
    final byRequest = <String, List<CaseThreadMessage>>{};
    for (final m in messages) {
      byRequest.putIfAbsent(m.requestId, () => []).add(m);
    }
    return [
      for (final entry in byRequest.entries)
        UnreadCaseCount(
          requestId: entry.key,
          unread: unreadForCase(
            messages: entry.value,
            myUserId: myUserId,
            lastReadAt: lastReadByRequest[entry.key],
          ),
        ),
    ];
  }

  int totalUnread(List<UnreadCaseCount> grouped) =>
      grouped.fold<int>(0, (sum, e) => sum + e.unread);

  int casesWithUnread(List<UnreadCaseCount> grouped) =>
      grouped.where((e) => e.unread > 0).length;

  static String badgeLabel(int count) {
    if (count <= 0) return '';
    if (count > 99) return '99+';
    return '$count';
  }
}
