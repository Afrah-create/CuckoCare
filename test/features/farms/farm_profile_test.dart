import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:cucocare/features/farms/domain/farm_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final older = DateTime.utc(2026, 1, 1);
  final newer = DateTime.utc(2026, 6, 1);

  test('saved profile stays primary after server version is cleared', () {
    final stub = _farm(
      id: 'stub',
      name: 'Draft',
      updatedAt: newer,
      serverVersion: 4,
    );
    final saved = _farm(
      id: 'saved',
      name: 'Kato Farm',
      district: 'Wakiso',
      village: 'Nansana',
      phone: '+256712345678',
      updatedAt: older,
    );

    final picked = selectPrimaryFarm(
      [stub, saved],
      const ['stub', 'saved'],
    );

    expect(picked?.id, 'saved');
    expect(isFarmProfileComplete(picked), isTrue);
  });

  test('reminder uses the completed profile instead of a name-only stub', () {
    final stub = _farm(id: 'stub', name: 'Draft', updatedAt: newer);
    final saved = _farm(
      id: 'saved',
      name: 'Kato Farm',
      district: 'Wakiso',
      village: 'Nansana',
      phone: '+256712345678',
      updatedAt: older,
    );

    final chosen = farmForReminder(stub, saved);

    expect(chosen?.id, 'saved');
    expect(farmDetailLabel(chosen), 'Kato Farm · Wakiso, Nansana');
  });

  test('synced farm wins over an empty local stub before a profile exists', () {
    final stub = _farm(id: 'stub', name: 'Draft', updatedAt: newer);
    final synced = _farm(
      id: 'synced',
      name: 'Server farm',
      updatedAt: older,
      serverVersion: 2,
    );

    final picked = selectPrimaryFarm(
      [stub, synced],
      const ['stub', 'synced'],
    );

    expect(picked?.id, 'synced');
  });
}

FarmRow _farm({
  required String id,
  required String name,
  required DateTime updatedAt,
  String? district,
  String? village,
  String? phone,
  int? serverVersion,
}) {
  return FarmRow(
    id: id,
    farmId: id,
    createdAt: updatedAt,
    updatedAt: updatedAt,
    name: name,
    district: district,
    village: village,
    phone: phone,
    serverVersion: serverVersion,
  );
}
