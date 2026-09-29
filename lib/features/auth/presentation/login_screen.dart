import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../domain/auth_repository.dart';
import 'login_controller.dart';
import 'login_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final login = ref.read(loginControllerProvider);
    final AuthSessionResult? session;
    if (login.formMode == AuthFormMode.signUp) {
      session = await ref.read(loginControllerProvider.notifier).signUpWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
            displayName: _displayNameController.text,
          );
    } else {
      session = await ref.read(loginControllerProvider.notifier).signInWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          );
    }

    if (session != null && mounted) {
      _goAfterAuth(session);
    }
  }

  void _goAfterAuth(AuthSessionResult session) {
    ref.invalidate(farmProfileIncompleteProvider);
    context.go('/home');
  }

  Future<void> _demoSession() async {
    await ref.read(loginControllerProvider.notifier).continueWithDemoSession();
    ref.invalidate(userProfileProvider);
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(connectivityOnlineProvider, (_, next) {
      ref
          .read(loginControllerProvider.notifier)
          .setOnline(next.value ?? true);
    });

    final login = ref.watch(loginControllerProvider);
    final env = ref.watch(envProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isSignUp = login.formMode == AuthFormMode.signUp;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.45),
              ),
              child: Column(
                children: [
                  Icon(Icons.egg_alt_outlined, size: 44, color: scheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    'CucoCare',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: SegmentedButton<AuthFormMode>(
                segments: const [
                  ButtonSegment(
                    value: AuthFormMode.signIn,
                    label: Text('Sign in'),
                  ),
                  ButtonSegment(
                    value: AuthFormMode.signUp,
                    label: Text('Create account'),
                  ),
                ],
                selected: {login.formMode},
                onSelectionChanged: login.isSubmitting
                    ? null
                    : (s) => ref
                        .read(loginControllerProvider.notifier)
                        .setFormMode(s.first),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!login.isOnline)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                'No connection.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (isSignUp) ...[
                            TextFormField(
                              controller: _displayNameController,
                              enabled: !login.isSubmitting,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Your name (optional)',
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            controller: _emailController,
                            enabled: !login.isSubmitting,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return 'Required';
                              }
                              if (!v.contains('@')) {
                                return 'Invalid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            enabled: !login.isSubmitting,
                            obscureText: login.obscurePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: login.isSubmitting
                                    ? null
                                    : () => ref
                                        .read(loginControllerProvider.notifier)
                                        .togglePasswordVisibility(),
                                icon: Icon(
                                  login.obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (value.length < 6) {
                                return 'At least 6 characters';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          if (login.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              login.errorMessage!,
                              style: TextStyle(color: scheme.error),
                            ),
                          ],
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: login.isSubmitting || !login.isOnline
                                ? null
                                : _submit,
                            child: login.isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(isSignUp ? 'Create account' : 'Sign in'),
                          ),
                          if (env.isDev) ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed:
                                  login.isSubmitting ? null : _demoSession,
                              child: const Text('Demo mode'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
