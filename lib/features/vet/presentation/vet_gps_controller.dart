import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/error/result.dart';
import '../../../core/error/user_messages.dart';
import 'vet_inbox_providers.dart';

enum VetGpsCapturePhase { idle, capturing }

class VetGpsCaptureState {
  const VetGpsCaptureState({
    this.phase = VetGpsCapturePhase.idle,
    this.errorMessage,
  });

  final VetGpsCapturePhase phase;
  final String? errorMessage;

  bool get isCapturing => phase == VetGpsCapturePhase.capturing;

  VetGpsCaptureState copyWith({
    VetGpsCapturePhase? phase,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VetGpsCaptureState(
      phase: phase ?? this.phase,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final vetGpsCaptureControllerProvider =
    NotifierProvider<VetGpsCaptureController, VetGpsCaptureState>(
  VetGpsCaptureController.new,
);

class VetGpsCaptureController extends Notifier<VetGpsCaptureState> {
  @override
  VetGpsCaptureState build() => const VetGpsCaptureState();

  Future<bool> captureAndUpload() async {
    state = state.copyWith(phase: VetGpsCapturePhase.capturing, clearError: true);
    final gps = await ref.read(farmGpsReaderProvider).captureCurrentPosition();
    switch (gps) {
      case Success(value: final reading):
        final upload =
            await ref.read(vetLocationRepositoryProvider).saveCurrentLocation(reading);
        switch (upload) {
          case Success():
            state = const VetGpsCaptureState();
            ref.invalidate(vetMapProvider);
            ref.invalidate(vetInboxProvider);
            return true;
          case Error(failure: final f):
            state = VetGpsCaptureState(errorMessage: userMessageForFailure(f));
            return false;
        }
      case Error(failure: final failure):
        state = VetGpsCaptureState(errorMessage: userMessageForFailure(failure));
        return false;
    }
  }
}
