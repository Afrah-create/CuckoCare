import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/programme_catalog_loader.dart';
import '../domain/programme_catalog.dart';

final programmeCatalogProvider = FutureProvider<ProgrammeCatalog>((ref) async {
  ref.keepAlive();
  return ProgrammeCatalogLoader().load();
});
