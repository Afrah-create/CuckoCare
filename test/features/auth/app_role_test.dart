import 'package:cucocare/features/auth/domain/app_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromWire maps roles', () {
    expect(AppRole.fromWire('vet'), AppRole.vet);
    expect(AppRole.fromWire('farmer'), AppRole.farmer);
    expect(AppRole.fromWire(null), AppRole.farmer);
    expect(AppRole.fromWire('unknown'), AppRole.farmer);
  });

  test('home locations differ by role', () {
    expect(AppRole.farmer.homeLocation, '/today');
    expect(AppRole.vet.homeLocation, '/vet');
  });
}
