import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data_platform/supabase/offline_first_auth.dart';
import '../domain/vet_profile.dart';

class VetProfileRepository {
  VetProfileRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Result<VetProfile>> fetchProfile() async {
    if (!await ensureSupabaseSessionForNetwork()) {
      return const Error(SyncAuthRequired());
    }
    try {
      final userId = _client.auth.currentUser!.id;
      final data = await _client
          .from('vet_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) {
        return Success(VetProfile(userId: userId));
      }
      return Success(VetProfile.fromJson(data));
    } on PostgrestException catch (e) {
      return Error(UnexpectedFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure('$e'));
    }
  }

  Future<Result<void>> saveProfile({
    required String? displayName,
    required String? organization,
    required String? district,
    required String? phone,
    required bool offersConsultation,
    required bool offersFarmVisit,
    required bool optedIn,
  }) async {
    if (!await ensureSupabaseSessionForNetwork()) {
      return const Error(SyncAuthRequired());
    }
    try {
      final userId = _client.auth.currentUser!.id;
      await _client.from('vet_profiles').upsert(
        {
          'user_id': userId,
          'display_name': displayName,
          'organization': organization,
          'district': district,
          'phone': phone,
          'offers_consultation': offersConsultation,
          'offers_farm_visit': offersFarmVisit,
          'opted_in': optedIn,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id',
      );
      return const Success(null);
    } on PostgrestException catch (e) {
      return Error(UnexpectedFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure('$e'));
    }
  }
}
