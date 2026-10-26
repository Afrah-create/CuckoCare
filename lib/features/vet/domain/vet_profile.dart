/// Domain model for a veterinarian's public and editable profile.
/// Pure Dart — no Flutter, Drift, or Supabase imports.
class VetProfile {
  const VetProfile({
    required this.userId,
    this.displayName,
    this.organization,
    this.district,
    this.phone,
    this.offersConsultation = true,
    this.offersFarmVisit = true,
    this.optedIn = true,
    this.isActive = true,
    this.isVerified = false,
    this.hasLocation = false,
  });

  final String userId;
  final String? displayName;
  final String? organization;
  final String? district;
  final String? phone;
  final bool offersConsultation;
  final bool offersFarmVisit;
  final bool optedIn;
  final bool isActive;
  final bool isVerified;
  final bool hasLocation;

  factory VetProfile.fromJson(Map<String, dynamic> json) => VetProfile(
        userId: json['user_id'] as String,
        displayName: json['display_name'] as String?,
        organization: json['organization'] as String?,
        district: json['district'] as String?,
        phone: json['phone'] as String?,
        offersConsultation: json['offers_consultation'] as bool? ?? true,
        offersFarmVisit: json['offers_farm_visit'] as bool? ?? true,
        optedIn: json['opted_in'] as bool? ?? true,
        isActive: json['is_active'] as bool? ?? true,
        isVerified: json['is_verified'] as bool? ?? false,
        hasLocation:
            json['latitude'] != null && json['longitude'] != null,
      );
}
