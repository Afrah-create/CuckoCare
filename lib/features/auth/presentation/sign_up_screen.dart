import 'package:flutter/material.dart';
import '../../../app/router/routes/typed_routes.dart';

/// Placeholder — sign-up UI lives on [LoginScreen] for now.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Center(
        child: FilledButton(
          onPressed: () => const LoginRoute().go(context),
          child: const Text('Back to sign in'),
        ),
      ),
    );
  }
}
