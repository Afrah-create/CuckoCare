import 'package:flutter/material.dart';

import '../domain/vet_case_workflow.dart';

Color vetMapPinColor({
  required String status,
  required String priority,
  required ColorScheme scheme,
}) {
  final urgentOpen = priority == 'urgent' &&
      (status == 'submitted' || status == 'received');
  if (urgentOpen) {
    return scheme.error;
  }
  return switch (status) {
    'submitted' || 'received' => scheme.primary,
    'accepted' => scheme.secondary,
    'in_progress' => scheme.tertiary,
    'completed' => scheme.outline,
    _ => scheme.onSurfaceVariant,
  };
}

IconData vetMapPinIcon(String status) {
  return switch (status) {
    'in_progress' => Icons.directions_car_filled_outlined,
    'completed' => Icons.check_circle_outline,
    'accepted' => Icons.handshake_outlined,
    _ => Icons.location_on,
  };
}

String vetMapLegendLine(String status) => vetRequestStatusLabel(status);
