import 'package:cucocare/app/di/providers.dart';

/// Fixed auth gate for navigation tests.
class FixedAuthSnapshotNotifier extends HasAuthSnapshotNotifier {
  FixedAuthSnapshotNotifier(this.value);

  final bool value;

  @override
  Future<bool> build() async => value;
}
