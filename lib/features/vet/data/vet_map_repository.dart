import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data_platform/supabase/offline_first_auth.dart';
import '../domain/vet_request_visibility.dart';

class VetMapRequest {
  VetMapRequest({
    required this.id,
    required this.farmId,
    required this.batchId,
    required this.healthRecordId,
    required this.serviceType,
    required this.status,
    required this.shareLocation,
    required this.priority,
    required this.createdAt,
    required this.summary,
    this.farmerNotes,
    this.affectedBirdCount,
    this.symptoms = const [],
    this.photoObjectKeys = const [],
    this.farmName,
    this.farmDistrict,
    this.farmVillage,
    this.latitude,
    this.longitude,
    this.requestedVetUserId,
    this.assignedVetUserId,
  });

  final String id;
  final String farmId;
  final String batchId;
  final String healthRecordId;
  final String serviceType;
  final String status;
  final bool shareLocation;
  final String priority;
  final DateTime createdAt;
  final String summary;
  final String? farmerNotes;
  final int? affectedBirdCount;
  final List<String> symptoms;
  final List<String> photoObjectKeys;
  final String? farmName;
  final String? farmDistrict;
  final String? farmVillage;
  final double? latitude;
  final double? longitude;
  final String? requestedVetUserId;
  final String? assignedVetUserId;

  bool get hasMapPin =>
      shareLocation && latitude != null && longitude != null;

  String get locationLabel {
    final parts = [
      if (farmVillage != null && farmVillage!.isNotEmpty) farmVillage,
      if (farmDistrict != null && farmDistrict!.isNotEmpty) farmDistrict,
    ];
    if (parts.isEmpty) {
      return farmName ?? 'Farm';
    }
    return parts.join(', ');
  }

  factory VetMapRequest.fromJson(Map<String, dynamic> json) {
    final symptomsRaw = json['symptoms'];
    final photosRaw = json['photo_object_keys'];
    return VetMapRequest(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      batchId: json['batch_id'] as String,
      healthRecordId: json['health_record_id'] as String,
      serviceType: json['service_type'] as String,
      status: json['status'] as String,
      shareLocation: json['share_location'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'normal',
      createdAt: DateTime.parse(json['created_at'] as String),
      summary: json['summary'] as String? ?? 'Health incident',
      farmerNotes: json['farmer_notes'] as String?,
      affectedBirdCount: json['affected_bird_count'] as int?,
      symptoms: symptomsRaw is List
          ? symptomsRaw.map((e) => e.toString()).toList()
          : const [],
      photoObjectKeys: photosRaw is List
          ? photosRaw.map((e) => e.toString()).toList()
          : const [],
      farmName: json['farm_name'] as String?,
      farmDistrict: json['farm_district'] as String?,
      farmVillage: json['farm_village'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      requestedVetUserId: json['requested_vet_user_id'] as String?,
      assignedVetUserId: json['assigned_vet_user_id'] as String?,
    );
  }
}

class VetMapRepository {
  VetMapRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Result<List<VetMapRequest>>> fetchMapRequests({int limit = 100}) async {
    if (!await ensureSupabaseSessionForNetwork()) {
      return const Error(SyncAuthRequired());
    }
    try {
      final raw = await _client.rpc(
        'vet_request_map',
        params: {'p_limit': limit},
      );
      if (raw is! Map<String, dynamic>) {
        return const Error(UnexpectedFailure('Unexpected vet_request_map response'));
      }
      final list = raw['requests'];
      if (list is! List) {
        return const Success([]);
      }
      final viewerId = _client.auth.currentUser?.id;
      final items = list
          .whereType<Map<String, dynamic>>()
          .map(VetMapRequest.fromJson)
          .where(
            (item) =>
                viewerId == null ||
                vetCanViewRequest(
                  assignedVetUserId: item.assignedVetUserId,
                  requestedVetUserId: item.requestedVetUserId,
                  viewerUserId: viewerId,
                ),
          )
          .toList();
      return Success(items);
    } on PostgrestException catch (e) {
      return Error(UnexpectedFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure('$e'));
    }
  }
}
