import 'package:flutter/material.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/layout/page_layout.dart';
import '../../../app/router/routes/typed_routes.dart';

/// Placeholder — sign-up UI lives on [LoginScreen] for now.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Create account',
      preset: PageLayout.form,
      body: Center(
        child: FilledButton(
          onPressed: () => const LoginRoute().go(context),
          child: const Text('Back to sign in'),
        ),
      ),
    );
  }
}
