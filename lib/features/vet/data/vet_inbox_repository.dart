import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data_platform/supabase/offline_first_auth.dart';
import '../../../data_platform/sync/sync_json.dart';
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
      id: syncJsonString(json['id'])!,
      farmId: syncJsonString(json['farm_id'])!,
      batchId: syncJsonString(json['batch_id']) ?? '',
      healthRecordId: syncJsonString(json['health_record_id']) ?? '',
      serviceType: syncJsonString(json['service_type']) ?? 'either',
      status: syncJsonString(json['status']) ?? 'submitted',
      shareLocation: syncJsonBool(json['share_location']),
      priority: syncJsonString(json['priority']) ?? 'normal',
      createdAt: syncJsonDateTime(json['created_at']) ?? DateTime.now().toUtc(),
      farmerNotes: syncJsonString(json['farmer_notes']),
      summary: syncJsonString(json['summary']),
      affectedBirdCount: syncJsonInt(json['affected_bird_count']),
      symptoms: symptomsRaw is List
          ? symptomsRaw.map((e) => e.toString()).toList()
          : const [],
      photoObjectKeys: photosRaw is List
          ? photosRaw.map((e) => e.toString()).toList()
          : const [],
      farmName: syncJsonString(json['farm_name']),
      farmDistrict: syncJsonString(json['farm_district']),
      farmVillage: syncJsonString(json['farm_village']),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      requestedVetUserId: syncJsonString(json['requested_vet_user_id']),
      assignedVetUserId: syncJsonString(json['assigned_vet_user_id']),
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
      final items = <VetInboxItem>[];
      for (final rawItem in list) {
        if (rawItem is! Map) {
          continue;
        }
        try {
          final item = VetInboxItem.fromJson(
            Map<String, dynamic>.from(rawItem),
          );
          if (viewerId == null ||
              vetCanViewRequest(
                assignedVetUserId: item.assignedVetUserId,
                requestedVetUserId: item.requestedVetUserId,
                viewerUserId: viewerId,
              )) {
            items.add(item);
          }
        } catch (_) {}
      }
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
