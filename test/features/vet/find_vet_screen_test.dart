import 'package:cucocare/app/di/providers.dart';
import 'package:cucocare/app/layout/layout_profile.dart';
import 'package:cucocare/app/layout/layout_scope.dart';
import 'package:cucocare/app/theme/app_theme.dart';
import 'package:cucocare/features/auth/domain/user_profile.dart';
import 'package:cucocare/features/vet/domain/available_vet.dart';
import 'package:cucocare/features/vet/presentation/find_vet_screen.dart';
import 'package:cucocare/features/vet/presentation/vet_inbox_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap() {
  const size = Size(360, 800);
  return MaterialApp(
    theme: AppTheme.light,
    home: LayoutScope(
      tokens: tokensFor(size),
      child: const MediaQuery(
        data: MediaQueryData(size: size, disableAnimations: true),
        child: FindVetScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('demo session asks the farmer to sign in', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith(
            (ref) async => const UserProfile(isDemo: true),
          ),
          primaryFarmProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: _wrap(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Sign in to find vets'), findsOneWidget);
  });

  testWidgets('populated list shows contact actions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith(
            (ref) async => const UserProfile(email: 'farmer@example.com'),
          ),
          primaryFarmProvider.overrideWith((ref) => Stream.value(null)),
          availableVetsProvider(null).overrideWith((ref) async {
            return AvailableVetsBrowse(
              vets: const [
                AvailableVet(
                  userId: 'u1',
                  displayName: 'Dr. Amina Nalwoga',
                  phone: '+256772123456',
                  distanceKm: 2.5,
                ),
              ],
              fetchedAt: DateTime.utc(2026, 10, 18),
              fromCache: false,
              farmHasLocation: true,
            );
          }),
        ],
        child: _wrap(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Dr. Amina Nalwoga'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('SMS'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
  });

  testWidgets('cached list shows the stale caption', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith(
            (ref) async => const UserProfile(email: 'farmer@example.com'),
          ),
          primaryFarmProvider.overrideWith((ref) => Stream.value(null)),
          availableVetsProvider(null).overrideWith((ref) async {
            return AvailableVetsBrowse(
              vets: const [
                AvailableVet(userId: 'u1', displayName: 'Dr. Cached'),
              ],
              fetchedAt: DateTime.now().subtract(const Duration(hours: 2)),
              fromCache: true,
              farmHasLocation: false,
            );
          }),
        ],
        child: _wrap(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Showing saved data'), findsOneWidget);
    expect(find.text('Add farm location'), findsOneWidget);
  });
}
