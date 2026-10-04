import '../data/vet_inbox_repository.dart';
import 'vet_request_visibility.dart';

/// Counts derived from a single [vet_inbox] fetch for dashboard UI.
class VetInboxStats {
  const VetInboxStats({
    required this.pending,
    required this.active,
    required this.inProgress,
    required this.acceptedNotStarted,
    required this.directedToYouPending,
    required this.urgentPending,
    required this.totalVisible,
  });

  final int pending;
  final int active;
  final int inProgress;
  final int acceptedNotStarted;
  final int directedToYouPending;
  final int urgentPending;
  final int totalVisible;

  bool get hasWork => pending > 0 || active > 0;

  static VetInboxStats fromItems(List<VetInboxItem> items, String vetUserId) {
    var pending = 0;
    var active = 0;
    var inProgress = 0;
    var acceptedNotStarted = 0;
    var directedToYouPending = 0;
    var urgentPending = 0;

    for (final item in items) {
      if (vetInboxItemIsPendingForVet(
        status: item.status,
        assignedVetUserId: item.assignedVetUserId,
        requestedVetUserId: item.requestedVetUserId,
        vetUserId: vetUserId,
      )) {
        pending++;
        if (item.requestedVetUserId == vetUserId) {
          directedToYouPending++;
        }
        if (item.priority == 'urgent') {
          urgentPending++;
        }
      }
      if (vetInboxItemIsActiveForVet(
        status: item.status,
        assignedVetUserId: item.assignedVetUserId,
        vetUserId: vetUserId,
      )) {
        active++;
        if (item.status == 'in_progress') {
          inProgress++;
        } else if (item.status == 'accepted') {
          acceptedNotStarted++;
        }
      }
    }

    return VetInboxStats(
      pending: pending,
      active: active,
      inProgress: inProgress,
      acceptedNotStarted: acceptedNotStarted,
      directedToYouPending: directedToYouPending,
      urgentPending: urgentPending,
      totalVisible: items.length,
    );
  }
}
