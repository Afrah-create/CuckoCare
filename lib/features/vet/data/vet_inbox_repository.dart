import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data_platform/supabase/offline_first_auth.dart';

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

  factory VetInboxItem.fromJson(Map<String, dynamic> json) {
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
      final items = list
          .whereType<Map<String, dynamic>>()
          .map(VetInboxItem.fromJson)
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
