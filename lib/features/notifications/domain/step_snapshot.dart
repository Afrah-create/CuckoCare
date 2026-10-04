import 'dart:convert';

String stepLabelFromSnapshot(String? snapshot, String fallback) {
  if (snapshot == null || snapshot.isEmpty) {
    return fallback;
  }
  try {
    final map = jsonDecode(snapshot) as Map<String, dynamic>;
    return map['label'] as String? ?? fallback;
  } catch (_) {
    return fallback;
  }
}

bool isHatcheryStepSnapshot(String? snapshot) {
  if (snapshot == null || snapshot.isEmpty) {
    return false;
  }
  try {
    final map = jsonDecode(snapshot) as Map<String, dynamic>;
    final location = map['location'] as String?;
    return location == 'hatchery';
  } catch (_) {
    return false;
  }
}
