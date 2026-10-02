import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../app/di/providers.dart';
import '../../../core/error/result.dart';
import '../../../core/error/user_messages.dart';

enum FarmGpsCapturePhase { idle, capturing }

class FarmGpsCaptureState {
  const FarmGpsCaptureState({
    this.phase = FarmGpsCapturePhase.idle,
    this.errorMessage,
  });

  final FarmGpsCapturePhase phase;
  final String? errorMessage;

  bool get isCapturing => phase == FarmGpsCapturePhase.capturing;

  FarmGpsCaptureState copyWith({
    FarmGpsCapturePhase? phase,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FarmGpsCaptureState(
      phase: phase ?? this.phase,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final farmGpsCaptureControllerProvider =
    NotifierProvider<FarmGpsCaptureController, FarmGpsCaptureState>(
  FarmGpsCaptureController.new,
);

class FarmGpsCaptureController extends Notifier<FarmGpsCaptureState> {
  @override
  FarmGpsCaptureState build() => const FarmGpsCaptureState();

  Future<bool> captureForFarm(String farmId) async {
    state = state.copyWith(
      phase: FarmGpsCapturePhase.capturing,
      clearError: true,
    );

    final result = await ref.read(farmGpsReaderProvider).captureCurrentPosition();
    switch (result) {
      case Success(value: final reading):
        try {
          await ref.read(farmRepositoryProvider).saveFarmGps(
                farmId: farmId,
                reading: reading,
              );
          ref.read(syncSchedulerProvider).notifyLocalWrite();
          state = const FarmGpsCaptureState();
          return true;
        } catch (e) {
          state = FarmGpsCaptureState(
            errorMessage: userMessageForError(e),
          );
          return false;
        }
      case Error(failure: final failure):
        state = FarmGpsCaptureState(
          errorMessage: userMessageForFailure(failure),
        );
        return false;
    }
  }

  Future<void> openSettingsForPermission() async {
    await Geolocator.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
