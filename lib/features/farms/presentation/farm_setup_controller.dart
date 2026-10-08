import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/di/providers.dart';
import '../../../core/error/user_messages.dart';
import '../../notifications/presentation/notification_prefs_provider.dart';

enum FarmSetupStatus { idle, submitting, failure, success }

class FarmSetupState {
  const FarmSetupState({
    this.status = FarmSetupStatus.idle,
    this.errorMessage,
  });

  final FarmSetupStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == FarmSetupStatus.submitting;

  FarmSetupState copyWith({
    FarmSetupStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FarmSetupState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final farmSetupControllerProvider =
    NotifierProvider<FarmSetupController, FarmSetupState>(
  FarmSetupController.new,
);

class FarmSetupController extends Notifier<FarmSetupState> {
  @override
  FarmSetupState build() => const FarmSetupState();

  Future<bool> submit({
    required String name,
    required String district,
    required String village,
    required String phone,
    String? altPhone,
    String? notes,
  }) async {
    state = state.copyWith(status: FarmSetupStatus.submitting, clearError: true);

    try {
      await ref.read(farmRepositoryProvider).saveFarmProfile(
            name: name,
            district: district,
            village: village,
            phone: phone,
            altPhone: altPhone,
            notes: notes,
          );
      ref.read(syncSchedulerProvider).notifyLocalWrite();
      ref.read(reminderReconcilerProvider).scheduleReconcile();
      state = state.copyWith(status: FarmSetupStatus.success);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: FarmSetupStatus.failure,
        errorMessage: userMessageForError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: FarmSetupStatus.failure,
        errorMessage: userMessageForError(e),
      );
      return false;
    }
  }
}
