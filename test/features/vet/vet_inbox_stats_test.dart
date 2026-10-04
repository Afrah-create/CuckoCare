import 'package:cucocare/features/vet/data/vet_inbox_repository.dart';
import 'package:cucocare/features/vet/domain/vet_inbox_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const me = 'vet-1';
  final now = DateTime.utc(2026, 3, 1);

  VetInboxItem item({
    required String id,
    required String status,
    String? assigned,
    String? requested,
    String priority = 'normal',
  }) {
    return VetInboxItem(
      id: id,
      farmId: 'farm',
      batchId: 'batch',
      healthRecordId: 'health',
      serviceType: 'either',
      status: status,
      shareLocation: false,
      priority: priority,
      createdAt: now,
      assignedVetUserId: assigned,
      requestedVetUserId: requested,
    );
  }

  test('counts pending and active separately', () {
    final stats = VetInboxStats.fromItems(
      [
        item(id: '1', status: 'submitted'),
        item(id: '2', status: 'accepted', assigned: me),
        item(id: '3', status: 'in_progress', assigned: me),
      ],
      me,
    );
    expect(stats.pending, 1);
    expect(stats.active, 2);
    expect(stats.inProgress, 1);
    expect(stats.acceptedNotStarted, 1);
    expect(stats.hasWork, isTrue);
  });

  test('directed and urgent pending', () {
    final stats = VetInboxStats.fromItems(
      [
        item(id: '1', status: 'submitted', requested: me),
        item(id: '2', status: 'received', priority: 'urgent'),
      ],
      me,
    );
    expect(stats.pending, 2);
    expect(stats.directedToYouPending, 1);
    expect(stats.urgentPending, 1);
  });
}
