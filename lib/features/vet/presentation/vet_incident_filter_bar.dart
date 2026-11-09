import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/widgets/filter_chip_strip.dart';
import '../domain/vet_incident_filters.dart';

class VetIncidentFilterBar extends StatelessWidget {
  const VetIncidentFilterBar({
    required this.value,
    required this.symptoms,
    required this.onChanged,
    super.key,
  });

  final VetIncidentFilters value;
  final List<String> symptoms;
  final ValueChanged<VetIncidentFilters> onChanged;

  static const _services = [
    FilterChipOption<String?>(value: null, label: 'Any service'),
    FilterChipOption<String?>(value: 'consultation', label: 'Consultation'),
    FilterChipOption<String?>(value: 'farm_visit', label: 'Farm visit'),
    FilterChipOption<String?>(value: 'either', label: 'Either'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilterChipStrip<String?>(
          selected: value.serviceType,
          options: _services,
          onSelected: (service) =>
              onChanged(value.copyWith(serviceType: () => service)),
        ),
        if (symptoms.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          FilterChipStrip<String?>(
            selected: value.symptom,
            options: [
              const FilterChipOption(value: null, label: 'All symptoms'),
              for (final symptom in symptoms)
                FilterChipOption(value: symptom, label: symptom),
            ],
            onSelected: (symptom) =>
                onChanged(value.copyWith(symptom: () => symptom)),
          ),
        ],
      ],
    );
  }
}
