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
      classifyPostgrest(code: '42501', message: 'forbidden'),
      isA<PermissionFailure>(),
    );
    expect(
      classifyPostgrest(code: '28000', message: 'not authenticated'),
      isA<SyncAuthRequired>(),
    );
  });

  test('AvailableVet list parses map-shaped RPC payload', () {
    final vets = [
      AvailableVet.fromJson({
        'user_id': 'u1',
        'display_name': 'Dr. Amina',
        'phone': null,
        'distance_km': 4,
      }),
    ];
    expect(vets.single.distanceKm, 4.0);
    expect(vets.single.phone, isNull);
  });
}
