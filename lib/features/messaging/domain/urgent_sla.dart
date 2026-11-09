class UrgentSla {
  const UrgentSla({
    this.acceptMinutes = 30,
    this.replyMinutes = 60,
  });

  final int acceptMinutes;
  final int replyMinutes;

  String waitingExplainer({required DateTime submittedAt}) {
    final by = submittedAt.add(Duration(minutes: replyMinutes));
    final h = by.toLocal().hour.toString().padLeft(2, '0');
    final m = by.toLocal().minute.toString().padLeft(2, '0');
    return "This is an urgent case. If the vet hasn't replied by $h:$m, we'll send them an SMS.";
  }
}
