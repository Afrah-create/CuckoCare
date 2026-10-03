import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data_platform/supabase/offline_first_auth.dart';
import '../domain/vet_request_visibility.dart';

class VetInboxItem {
  VetInboxItem({
    required this.id,
    required this.farmId,
    required this.batchId,
    required this.healthRecordId,
    required this.serviceType,
    required this.status,
    required this.shareLocation,
    required this.priority,
    required this.createdAt,
    this.farmerNotes,
    this.summary,
    this.affectedBirdCount,
    this.symptoms = const [],
    this.photoObjectKeys = const [],
    this.farmName,
    this.farmDistrict,
    this.farmVillage,
    this.distanceKm,
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
  final String? farmerNotes;
  final String? summary;
  final int? affectedBirdCount;
  final List<String> symptoms;
  final List<String> photoObjectKeys;
  final String? farmName;
  final String? farmDistrict;
  final String? farmVillage;
  final double? distanceKm;
  final String? requestedVetUserId;
  final String? assignedVetUserId;

  bool get isDirectedRequest => requestedVetUserId != null;

  String get farmLocationLabel {
    final parts = [
      if (farmVillage != null && farmVillage!.isNotEmpty) farmVillage,
      if (farmDistrict != null && farmDistrict!.isNotEmpty) farmDistrict,
    ];
    if (parts.isNotEmpty) {
      return parts.join(', ');
    }
    return farmName ?? 'Farm';
  }

  factory VetInboxItem.fromJson(Map<String, dynamic> json) {
    final symptomsRaw = json['symptoms'];
    final photosRaw = json['photo_object_keys'];
    return VetInboxItem(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      batchId: json['batch_id'] as String,
      healthRecordId: json['health_record_id'] as String,
      serviceType: json['service_type'] as String,
      status: json['status'] as String,
      shareLocation: json['share_location'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'normal',
      createdAt: DateTime.parse(json['created_at'] as String),
      farmerNotes: json['farmer_notes'] as String?,
      summary: json['summary'] as String?,
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
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      requestedVetUserId: json['requested_vet_user_id'] as String?,
      assignedVetUserId: json['assigned_vet_user_id'] as String?,
    );
  }
}

class VetInboxRepository {
  VetInboxRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Result<List<VetInboxItem>>> fetchInbox({int limit = 50}) async {
    if (!await ensureSupabaseSessionForNetwork()) {
      return const Error(SyncAuthRequired());
    }
    try {
      final raw = await _client.rpc(
        'vet_inbox',
        params: {'p_limit': limit},
      );
      if (raw is! Map<String, dynamic>) {
        return const Error(UnexpectedFailure('Unexpected vet_inbox response'));
      }
      final list = raw['requests'];
      if (list is! List) {
        return const Success([]);
      }
      final viewerId = _client.auth.currentUser?.id;
      final items = list
          .whereType<Map<String, dynamic>>()
          .map(VetInboxItem.fromJson)
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

  Future<Result<VetInboxItem>> setRequestStatus({
    required String requestId,
    required String status,
  }) async {
    if (!await ensureSupabaseSessionForNetwork()) {
      return const Error(SyncAuthRequired());
    }
    try {
      final raw = await _client.rpc(
        'vet_set_request_status',
        params: {
          'p_request_id': requestId,
          'p_status': status,
        },
      );
      if (raw is! Map<String, dynamic>) {
        return const Error(UnexpectedFailure('Unexpected status response'));
      }
      return Success(VetInboxItem.fromJson(raw));
    } on PostgrestException catch (e) {
      return Error(UnexpectedFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure('$e'));
    }
  }
}
