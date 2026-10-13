import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data_platform/supabase/offline_first_auth.dart';

class AvailableVet {
  AvailableVet({
    required this.userId,
    required this.displayName,
    this.organization,
    this.district,
    this.phone,
    required this.offersConsultation,
    required this.offersFarmVisit,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  final String userId;
  final String displayName;
  final String? organization;
  final String? district;

  /// E.164-formatted phone (e.g. +256701234567). May be null if not shared.
  final String? phone;

  final bool offersConsultation;
  final bool offersFarmVisit;
  final double? latitude;
  final double? longitude;
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

  factory AvailableVet.fromJson(Map<String, dynamic> json) {
    return AvailableVet(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String? ?? 'Veterinarian',
      organization: json['organization'] as String?,
      district: json['district'] as String?,
      phone: json['phone'] as String?,
      offersConsultation: json['offers_consultation'] as bool? ?? true,
      offersFarmVisit: json['offers_farm_visit'] as bool? ?? true,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }
}

class VetDirectoryRepository {
  VetDirectoryRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Result<List<AvailableVet>>> listAvailableVets({String? farmId}) async {
    if (!await ensureSupabaseSessionForNetwork()) {
      return const Error(SyncAuthRequired());
    }
    try {
      final raw = await _client.rpc(
        'list_available_vets',
        params: {'p_farm_id': ?farmId},
      );
      if (raw is! Map<String, dynamic>) {
        return const Error(UnexpectedFailure('Unexpected vet list response'));
      }
      final list = raw['vets'];
      if (list is! List) {
        return const Success([]);
      }
      return Success(
        list.whereType<Map<String, dynamic>>().map(AvailableVet.fromJson).toList(),
      );
    } on PostgrestException catch (e) {
      return Error(UnexpectedFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure('$e'));
    }
  }
}
