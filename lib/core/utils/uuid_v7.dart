import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Client-generated IDs (UUID v7 when available).
String newId() => _uuid.v7();
