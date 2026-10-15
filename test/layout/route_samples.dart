import 'package:cucocare/app/layout/app_page.dart';
import 'package:cucocare/app/layout/page_layout.dart';
import 'package:cucocare/features/auth/presentation/sign_up_screen.dart';
import 'package:cucocare/features/feed/presentation/feed_screen.dart';
import 'package:flutter/material.dart';

PageLayout presetForRoute(String path) {
  return switch (path) {
    '/splash' || '/vet/map' => PageLayout.fullBleed,
    '/batches/:batchId' ||
    '/batches/:batchId/vaccinations/:taskId' ||
    '/batches/:batchId/losses' ||
    '/feed/:feedItemId' ||
    '/vet/incident' =>
      PageLayout.reading,
    '/auth/login' ||
    '/auth/signup' ||
    '/auth/forgot-password' ||
    '/batches/new' ||
    '/batches/:batchId/edit' ||
    '/batches/:batchId/losses/new' ||
    '/batches/:batchId/losses/:lossId' ||
    '/more' ||
    '/more/farm' ||
    '/more/settings/notifications' ||
    '/vet/more' =>
      PageLayout.form,
    _ => PageLayout.standard,
  };
}

/// Paths that must stay in lockstep with the router. A new route fails the
/// matrix until it is added here.
const routeSamplePaths = <String>{
  '/auth/forgot-password',
  '/auth/login',
  '/auth/signup',
  '/batches',
  '/batches/:batchId',
  '/batches/:batchId/vaccinations/:taskId',
  '/batches/:batchId/edit',
  '/batches/:batchId/losses',
  '/batches/:batchId/losses/new',
  '/batches/:batchId/losses/:lossId',
  '/batches/new',
  '/feed',
  '/feed/:feedItemId',
  '/more',
  '/more/farm',
  '/more/settings/notifications',
  '/records',
  '/splash',
  '/today',
  '/vet',
  '/vet/active',
  '/vet/incident',
  '/vet/map',
  '/vet/more',
};

Widget routeSample(String path) {
  if (!routeSamplePaths.contains(path)) {
    throw ArgumentError('No layout sample for $path');
  }
  return switch (path) {
    '/auth/signup' => const SignUpScreen(),
    '/feed' => const FeedScreen(),
    _ => RouteChromeSample(path: path, preset: presetForRoute(path)),
  };
}

/// Page chrome used where the real screen needs the database or auth graph.
class RouteChromeSample extends StatelessWidget {
  const RouteChromeSample({required this.path, required this.preset, super.key});

  final String path;
  final PageLayout preset;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: path,
      preset: preset,
      primary: preset != PageLayout.fullBleed,
      scroll: preset != PageLayout.fullBleed,
      frame: preset != PageLayout.fullBleed,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(path),
          const SizedBox(height: 16),
          FilledButton(onPressed: () {}, child: const Text('Primary action')),
        ],
      ),
    );
  }
}
