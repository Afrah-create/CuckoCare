import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped on sign-out so login fields and autofill state reset.
class AuthFormGenerationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final authFormGenerationProvider =
    NotifierProvider<AuthFormGenerationNotifier, int>(
  AuthFormGenerationNotifier.new,
);

void bumpAuthFormGeneration(WidgetRef ref) {
  ref.read(authFormGenerationProvider.notifier).bump();
}
