import '../../health/domain/incident_symptoms.dart';

/// Symptom + service filters applied on top of the Requests/Active queue.
class VetIncidentFilters {
  const VetIncidentFilters({
    this.serviceType,
    this.symptom,
  });

  final String? serviceType;
  final String? symptom;

  bool get isActive => serviceType != null || symptom != null;

  VetIncidentFilters copyWith({
    String? Function()? serviceType,
    String? Function()? symptom,
  }) {
    return VetIncidentFilters(
      serviceType: serviceType != null ? serviceType() : this.serviceType,
      symptom: symptom != null ? symptom() : this.symptom,
    );
  }

  bool matches({
    required String serviceType,
    required List<String> symptoms,
  }) {
    if (this.serviceType != null && serviceType != this.serviceType) {
      return false;
    }
    if (symptom != null && !symptoms.contains(symptom)) {
      return false;
    }
    return true;
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
