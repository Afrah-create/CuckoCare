import 'package:cucocare/core/error/failure.dart';
import 'package:cucocare/features/vet/data/vet_directory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classifyPostgrest maps RPC codes', () {
    expect(
      classifyPostgrest(code: 'PGRST202', message: 'schema cache'),
      isA<SyncServerFailure>(),
    );
    expect(
      classifyPostgrest(
        code: 'PGRST203',
        message: 'Could not choose the best candidate function',
      ),
      isA<SyncServerFailure>(),
    );
    expect(
      classifyPostgrest(code: '42501', message: 'forbidden'),
      isA<PermissionFailure>(),
    );
    expect(
      classifyPostgrest(code: '28000', message: 'not authenticated'),
      isA<SyncAuthRequired>(),
    );
  });

  test('parseListAvailableVets reads wrapped jsonb and table rows', () {
    final wrapped = parseListAvailableVets({
      'vets': [
        {
          'user_id': 'u1',
          'display_name': 'Dr. Amina',
          'phone': '+256700000001',
          'distance_km': '4.2',
          'offers_consultation': 1,
        },
      ],
    });
    expect(wrapped.single.displayName, 'Dr. Amina');
    expect(wrapped.single.distanceKm, 4.2);
    expect(wrapped.single.offersConsultation, isTrue);

    final nested = parseListAvailableVets({
      'list_available_vets': {
        'vets': [
          {'user_id': 'u2', 'display_name': 'Dr. Musa'},
        ],
      },
    });
    expect(nested.single.userId, 'u2');

    final table = parseListAvailableVets([
      {'user_id': 'u3', 'display_name': 'Dr. Table'},
    ]);
    expect(table.single.userId, 'u3');

    expect(parseListAvailableVets('{"vets":[]}'), isEmpty);
  });
}
