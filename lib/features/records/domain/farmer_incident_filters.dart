import '../../health/domain/incident_symptoms.dart';

enum FarmerIncidentQueue { all, awaiting, withVet, closed, draft }

enum FarmerIncidentSort { newest, oldest, mostAffected }

/// Farmer Records → Health: queue, symptom, and sort.
class FarmerIncidentFilters {
  const FarmerIncidentFilters({
    this.queue = FarmerIncidentQueue.all,
    this.symptom,
    this.sort = FarmerIncidentSort.newest,
  });

  final FarmerIncidentQueue queue;
  final String? symptom;
  final FarmerIncidentSort sort;

  bool get isActive =>
      queue != FarmerIncidentQueue.all ||
      symptom != null ||
      sort != FarmerIncidentSort.newest;

  FarmerIncidentFilters copyWith({
    FarmerIncidentQueue? queue,
    String? Function()? symptom,
    FarmerIncidentSort? sort,
  }) {
    return FarmerIncidentFilters(
      queue: queue ?? this.queue,
      symptom: symptom != null ? symptom() : this.symptom,
      sort: sort ?? this.sort,
    );
  }

  bool matches({
    required String? requestStatus,
    required List<String> symptoms,
  }) {
    if (!_matchesQueue(requestStatus)) {
      return false;
    }
    if (symptom != null && !symptoms.contains(symptom)) {
      return false;
    }
    return true;
  }

  bool _matchesQueue(String? status) {
    return switch (queue) {
      FarmerIncidentQueue.all => true,
      FarmerIncidentQueue.awaiting =>
        status == 'submitted' || status == 'received',
      FarmerIncidentQueue.withVet =>
        status == 'accepted' || status == 'in_progress',
      FarmerIncidentQueue.closed =>
        status == 'completed' ||
            status == 'declined' ||
            status == 'cancelled',
      FarmerIncidentQueue.draft => status == 'draft' || status == null,
    };
  }

  int compare({
    required DateTime aOccurredOn,
    required DateTime bOccurredOn,
    required int? aAffected,
    required int? bAffected,
  }) {
    return switch (sort) {
      FarmerIncidentSort.newest => bOccurredOn.compareTo(aOccurredOn),
      FarmerIncidentSort.oldest => aOccurredOn.compareTo(bOccurredOn),
      FarmerIncidentSort.mostAffected =>
        (bAffected ?? -1).compareTo(aAffected ?? -1),
    };
  }

  static List<String> symptomsPresent(Iterable<List<String>> itemSymptoms) {
    final seen = <String>{};
    for (final symptoms in itemSymptoms) {
      seen.addAll(symptoms);
    }
    return [
      for (final label in commonIncidentSymptoms)
        if (seen.contains(label)) label,
      ...seen.where((s) => !commonIncidentSymptoms.contains(s)),
    ];
  }
}
