import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';

import '../../../app/di/providers.dart';
import '../../../data_platform/sync/sync_apply.dart';
import '../../../data_platform/supabase/supabase_bootstrap.dart';
import '../../auth/domain/app_role.dart';
import '../data/case_message_repository.dart';
import '../data/link_quality_service.dart';
import '../data/media_uploader.dart';
import '../data/message_realtime_service.dart';
import '../data/vet_case_message_hydrator.dart';
import '../domain/case_thread.dart';
import '../domain/link_quality.dart';

final caseMessageRepositoryProvider = Provider<CaseMessageRepository>((ref) {
  return CaseMessageRepository(
    db: ref.watch(appDatabaseProvider),
    write: ref.watch(syncedWriteProvider),
    clock: ref.watch(clockProvider),
    currentUserId: () => ref.read(authUserIdProvider).value ?? '',
    farmRole: () async => (await ref.read(farmRoleProvider.future)).name,
    isVet: () => ref.read(appRoleProvider).value == AppRole.vet,
    vetSend: ({
      required String id,
      required String requestId,
      required String kind,
      required String? body,
      required DateTime clientCreatedAt,
    }) async {
      final raw = await supabaseClient.rpc(
        'send_case_message',
        params: {
          'p_id': id,
          'p_request_id': requestId,
          'p_kind': kind,
          'p_body': body,
          'p_client_created_at': clientCreatedAt.toIso8601String(),
        },
      );
      return Map<String, dynamic>.from(raw as Map);
    },
    vetMarkRead: ({required String requestId, required String messageId}) async {
      await supabaseClient.rpc(
        'mark_case_read',
        params: {
          'p_request_id': requestId,
          'p_message_id': messageId,
        },
      );
    },
  );
});

final caseThreadProvider =
    StreamProvider.family<List<CaseThreadMessage>, String>((ref, requestId) {
  return ref.watch(caseMessageRepositoryProvider).watchThread(requestId);
});

final caseUnreadProvider = StreamProvider.family<int, String>((ref, requestId) {
  return ref.watch(caseMessageRepositoryProvider).watchUnreadForRequest(requestId);
});

final farmUnreadProvider = StreamProvider<int>((ref) {
  final farmId = ref.watch(primaryFarmProvider).value?.id;
  if (farmId == null) return Stream.value(0);
  return ref.watch(caseMessageRepositoryProvider).watchFarmUnread(farmId);
});

final navUnreadProvider = StreamProvider<int>((ref) {
  final role = ref.watch(appRoleProvider).value;
  if (role == AppRole.vet) {
    return ref.watch(caseMessageRepositoryProvider).watchAllUnread();
  }
  final farmId = ref.watch(primaryFarmProvider).value?.id;
  if (farmId == null) return Stream.value(0);
  return ref.watch(caseMessageRepositoryProvider).watchFarmUnread(farmId);
});

final newestUnreadHintProvider = StreamProvider((ref) {
  return ref.watch(caseMessageRepositoryProvider).watchNewestUnreadHint();
});

final linkQualityServiceProvider = Provider<LinkQualityService>((ref) {
  return LinkQualityService();
});

final linkQualityProvider = Provider<LinkQualityLevel>((ref) {
  final online = ref.watch(connectivityOnlineProvider).value ?? true;
  if (!online) return LinkQualityLevel.none;
  return ref.watch(linkQualityServiceProvider).level;
});

final vetCaseHydratorProvider = Provider<VetCaseMessageHydrator>((ref) {
  return VetCaseMessageHydrator(SyncApply(ref.watch(appDatabaseProvider)));
});

final mediaUploaderProvider = Provider<MediaUploader>((ref) {
  return MediaUploader(
    db: ref.watch(appDatabaseProvider),
    write: ref.watch(syncedWriteProvider),
    clock: ref.watch(clockProvider),
  );
});

final caseRadioForegroundProvider = Provider<MessageRealtimeService>((ref) {
  final service = MessageRealtimeService(
    requestPull: () async {
      await ref.read(syncEngineProvider).requestPull();
    },
    linkQuality: () => ref.read(linkQualityProvider),
  );
  ref.onDispose(service.detach);
  final farmId = ref.watch(primaryFarmProvider).value?.id;
  service.attach(farmId: farmId);
  final role = ref.watch(appRoleProvider).value;
  if (role == AppRole.vet) {
    unawaited(() async {
      try {
        await ref.read(vetCaseHydratorProvider).pullAssigned();
      } catch (_) {}
    }());
  }
  return service;
});
