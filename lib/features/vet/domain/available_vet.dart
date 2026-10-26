class AvailableVet {
  const AvailableVet({
    required this.userId,
    required this.displayName,
    this.organization,
    this.district,
    this.phone,
    this.offersConsultation = true,
    this.offersFarmVisit = true,
    this.distanceKm,
  });

  final String userId;
  final String displayName;
  final String? organization;
  final String? district;
  final String? phone;
  final bool offersConsultation;
  final bool offersFarmVisit;
  final double? distanceKm;

  String get subtitle {
    final parts = <String>[];
    if (organization != null && organization!.trim().isNotEmpty) {
      parts.add(organization!.trim());
    }
    if (district != null && district!.trim().isNotEmpty) {
      parts.add(district!.trim());
    }
    if (distanceKm != null) {
      parts.add('${distanceKm!.toStringAsFixed(1)} km away');
    }
    return parts.isEmpty ? 'Veterinary officer' : parts.join(' · ');
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'display_name': displayName,
        'organization': organization,
        'district': district,
        'phone': phone,
        'offers_consultation': offersConsultation,
        'offers_farm_visit': offersFarmVisit,
        'distance_km': distanceKm,
      };

  factory AvailableVet.fromJson(Map<String, dynamic> json) {
    return AvailableVet(
      userId: json['user_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'Veterinarian',
      organization: json['organization'] as String?,
      district: json['district'] as String?,
      phone: json['phone'] as String?,
      offersConsultation: json['offers_consultation'] as bool? ?? true,
      offersFarmVisit: json['offers_farm_visit'] as bool? ?? true,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }
}

class AvailableVetsBrowse {
  const AvailableVetsBrowse({
    required this.vets,
    required this.fetchedAt,
    required this.fromCache,
    required this.farmHasLocation,
    this.farmNeedsSync = false,
  });

  final List<AvailableVet> vets;
  final DateTime fetchedAt;
  final bool fromCache;
  final bool farmHasLocation;
  final bool farmNeedsSync;
}
