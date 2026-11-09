import 'package:cucocare/features/records/domain/farmer_incident_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('queue chips match request status', () {
    const awaiting = FarmerIncidentFilters(queue: FarmerIncidentQueue.awaiting);
    expect(
      awaiting.matches(requestStatus: 'submitted', symptoms: const []),
      isTrue,
    );
    expect(
      awaiting.matches(requestStatus: 'accepted', symptoms: const []),
      isFalse,
    );

    const withVet = FarmerIncidentFilters(queue: FarmerIncidentQueue.withVet);
    expect(
      withVet.matches(requestStatus: 'in_progress', symptoms: const []),
      isTrue,
    );

    const draft = FarmerIncidentFilters(queue: FarmerIncidentQueue.draft);
    expect(draft.matches(requestStatus: null, symptoms: const []), isTrue);
    expect(
      draft.matches(requestStatus: 'submitted', symptoms: const []),
      isFalse,
    );
  });

  test('symptom filter requires the tag', () {
    const filters = FarmerIncidentFilters(symptom: 'Diarrhea');
    expect(
      filters.matches(
        requestStatus: 'submitted',
        symptoms: const ['Diarrhea', 'Sudden deaths'],
      ),
      isTrue,
    );
    expect(
      filters.matches(
        requestStatus: 'submitted',
        symptoms: const ['Coughing / sneezing'],
      ),
      isFalse,
    );
  });

  test('sort newest vs most affected', () {
    const newest = FarmerIncidentFilters();
    expect(
      newest.compare(
        aOccurredOn: DateTime(2026, 11, 9),
        bOccurredOn: DateTime(2026, 11, 8),
        aAffected: 5,
        bAffected: 50,
      ),
      lessThan(0),
    );

    const birds = FarmerIncidentFilters(
      sort: FarmerIncidentSort.mostAffected,
    );
    expect(
      birds.compare(
        aOccurredOn: DateTime(2026, 11, 9),
        bOccurredOn: DateTime(2026, 11, 8),
        aAffected: 5,
        bAffected: 50,
      ),
      greaterThan(0),
    );
  });
}
