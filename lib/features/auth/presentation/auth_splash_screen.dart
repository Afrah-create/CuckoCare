import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';

/// Shown while local session state is resolved (cold start).
class AuthSplashScreen extends ConsumerStatefulWidget {
  const AuthSplashScreen({super.key});

  @override
  ConsumerState<AuthSplashScreen> createState() => _AuthSplashScreenState();
}

class _AuthSplashScreenState extends ConsumerState<AuthSplashScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(hasAuthSnapshotProvider, (_, next) => _goWhenReady(next));

    final authAsync = ref.watch(hasAuthSnapshotProvider);
    _goWhenReady(authAsync);

    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.egg_alt, size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'CucoCare',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Poultry farm management',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              if (authAsync.isLoading)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              else if (authAsync.hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Could not read local session. You can still sign in.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _goWhenReady(AsyncValue<bool> authAsync) {
    if (_navigated || authAsync.isLoading) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _navigated) {
        return;
      }
      final location = GoRouterState.of(context).matchedLocation;
      if (location != '/splash') {
        return;
      }
      _navigated = true;
      if (authAsync.hasError || !(authAsync.value ?? false)) {
        context.go('/login');
        return;
      }
      context.go('/home');
    });
  }
}
