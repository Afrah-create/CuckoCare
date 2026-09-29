abstract class ReminderScheduler {
  Future<void> reconcile({int maxScheduled = 50});

  Future<void> cancelAll();
}
