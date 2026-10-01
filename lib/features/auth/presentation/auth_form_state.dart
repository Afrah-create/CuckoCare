import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persisted email and display name across auth mode switches (never password).
class AuthFormPersisted {
  const AuthFormPersisted({this.email = '', this.displayName = ''});

  final String email;
  final String displayName;

  AuthFormPersisted copyWith({String? email, String? displayName}) {
    return AuthFormPersisted(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }
}

class AuthFormStateNotifier extends Notifier<AuthFormPersisted> {
  @override
  AuthFormPersisted build() => const AuthFormPersisted();

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateDisplayName(String name) {
    state = state.copyWith(displayName: name);
  }
}

final authFormStateProvider =
    NotifierProvider<AuthFormStateNotifier, AuthFormPersisted>(
  AuthFormStateNotifier.new,
);
