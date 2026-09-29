import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:cucocare/features/auth/data/auth_snapshot_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('persistFromSupabaseUser uses singleton id 1', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = AuthSnapshotRepository(db);

    final user = User.fromJson({
      'id': '6a3fe803-ba83-4fcf-a935-364283b7ad29',
      'aud': 'authenticated',
      'email': 'test@example.com',
      'created_at': DateTime.utc(2024, 1, 1).toIso8601String(),
      'app_metadata': <String, dynamic>{},
      'user_metadata': <String, dynamic>{},
    })!;

    await repo.persistFromSupabaseUser(user);

    final row = await db.select(db.authSnapshot).getSingle();
    expect(row.id, 1);
    expect(row.email, 'test@example.com');
  });
}
