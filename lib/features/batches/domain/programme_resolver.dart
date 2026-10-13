import 'programme_catalog.dart';

enum BirdType { broiler, layer, dualPurpose, local }

enum ProductionType { egg, meat }

class ProgrammeResolver {
  const ProgrammeResolver();

  ProgrammeKey? resolve({
    required BirdType birdType,
    ProductionType? productionType,
  }) {
    return switch (birdType) {
      BirdType.broiler => ProgrammeKey.broiler,
      BirdType.layer => ProgrammeKey.layer,
      BirdType.dualPurpose => switch (productionType) {
        ProductionType.egg => ProgrammeKey.layer,
        ProductionType.meat => ProgrammeKey.broiler,
        null => null,
      },
      BirdType.local => null,
    };
  }
}
