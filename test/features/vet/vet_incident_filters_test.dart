import 'package:cucocare/features/vet/data/vet_inbox_repository.dart';
import 'package:cucocare/features/vet/domain/vet_incident_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  VetInboxItem item({
    String service = 'either',
    List<String> symptoms = const [],
  }) {
    return VetInboxItem(
      id: '1',
      farmId: 'farm',
      batchId: 'batch',
      healthRecordId: 'health',
      serviceType: service,
      status: 'submitted',
      shareLocation: false,
      priority: 'normal',
      createdAt: DateTime.utc(2026, 3, 1),
      symptoms: symptoms,
    );
  }

  test('service and symptom filters combine', () {
    const filters = VetIncidentFilters(
      serviceType: 'farm_visit',
      symptom: 'Coughing / sneezing',
    );
    expect(
      filters.matches(
        serviceType: 'farm_visit',
        symptoms: const ['Coughing / sneezing'],
      ),
      isTrue,
    );
    expect(
      filters.matches(
        serviceType: 'consultation',
        symptoms: const ['Coughing / sneezing'],
      ),
      isFalse,
    );
    expect(
      filters.matches(
        serviceType: 'farm_visit',
        symptoms: const ['Diarrhea'],
      ),
      isFalse,
    );
  });

  test('fromJson reads numeric affected count', () {
    final parsed = VetInboxItem.fromJson({
      'id': 'a',
      'farm_id': 'f',
      'batch_id': 'b',
      'health_record_id': 'h',
      'service_type': 'either',
      'status': 'submitted',
      'share_location': false,
      'priority': 'normal',
      'created_at': '2026-03-01T12:00:00Z',
      'affected_bird_count': 12.0,
      'symptoms': ['Coughing / sneezing'],
    });
    expect(parsed.affectedBirdCount, 12);
    expect(parsed.symptoms, ['Coughing / sneezing']);
  });

  test('symptomsPresent keeps catalogue order', () {
    final ordered = VetIncidentFilters.symptomsPresent([
      item(symptoms: const ['Limping', 'Coughing / sneezing']).symptoms,
    ]);
    expect(ordered.first, 'Coughing / sneezing');
    expect(ordered, contains('Limping'));
  });
}
