import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/error/user_messages.dart';

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
      state = state.copyWith(status: FarmSetupStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: FarmSetupStatus.failure,
        errorMessage: userMessageForError(e),
      );
      return false;
    }
  }
}
