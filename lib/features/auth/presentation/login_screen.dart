import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_form_state.dart';
import 'login_form.dart';

/// Sign-in / create-account credentials (wrapped by [AuthShell] in the router).
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generation = ref.watch(authFormGenerationProvider);
    return LoginForm(key: ValueKey('login-$generation'));
  }
}
