enum ReminderKind {
  scheduleDue,
  scheduleOverdue,
}

class PlannedReminder {
  const PlannedReminder({
    required this.notificationId,
    required this.kind,
    required this.fireAtLocal,
    required this.title,
    required this.body,
    required this.payload,
    required this.contentHash,
    required this.farmId,
  });

  final int notificationId;
  final ReminderKind kind;
  final DateTime fireAtLocal;
  final String title;
  final String body;
  final String payload;
  final String contentHash;
  final String farmId;
}
