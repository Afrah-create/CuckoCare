import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(envProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'First sign-in requires internet. After that, CucoCare works fully offline with your local records.',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                // Scaffold: Supabase auth UI comes later.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Online sign-in flow not built in scaffold.'),
                  ),
                );
              },
              child: const Text('Sign in with phone or email'),
            ),
            if (env.isDev) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await ref
                      .read(authSnapshotRepositoryProvider)
                      .saveDemoSnapshot();
                  ref.invalidate(hasAuthSnapshotProvider);
                },
                child: const Text('Dev: continue with offline demo session'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
