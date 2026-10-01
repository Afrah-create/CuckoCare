import 'package:flutter/material.dart';

import 'login_form.dart';

/// Sign-in / create-account credentials (wrapped by [AuthShell] in the router).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginForm();
  }
}
