import 'package:cucocare/core/error/user_messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps host lookup errors to friendly copy', () {
    expect(
      userMessageForError(
        Exception('ClientException: SocketException: Failed host lookup'),
      ),
      contains('internet'),
    );
  });

  test('maps invalid credentials', () {
    expect(
      mapSupabaseAuthMessage('Invalid login credentials'),
      'Email or password is incorrect.',
    );
  });
}
