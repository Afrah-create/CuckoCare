import 'package:cucocare/features/messaging/domain/messaging_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rules = MessagingRules();

  group('canSend', () {
    test('owner can send on accepted', () {
      expect(
        rules.canSend(
          requestStatus: 'accepted',
          farmRole: 'owner',
          isAssignedVet: false,
          requestDeleted: false,
        ),
        isTrue,
      );
    });

    test('viewer cannot send', () {
      expect(
        rules.canSend(
          requestStatus: 'accepted',
          farmRole: 'viewer',
          isAssignedVet: false,
          requestDeleted: false,
        ),
        isFalse,
      );
    });

    test('assigned vet can send while in progress', () {
      expect(
        rules.canSend(
          requestStatus: 'in_progress',
          farmRole: 'viewer',
          isAssignedVet: true,
          requestDeleted: false,
        ),
        isTrue,
      );
    });

    test('closed cases are read only', () {
      for (final status in ['completed', 'cancelled', 'declined']) {
        expect(
          rules.canSend(
            requestStatus: status,
            farmRole: 'owner',
            isAssignedVet: true,
            requestDeleted: false,
          ),
          isFalse,
        );
      }
    });

    test('waiting statuses cannot send', () {
      for (final status in ['submitted', 'received', 'draft']) {
        expect(
          rules.canSend(
            requestStatus: status,
            farmRole: 'owner',
            isAssignedVet: false,
            requestDeleted: false,
          ),
          isFalse,
        );
      }
    });
  });

  test('validateText', () {
    expect(rules.validateText('  '), 'empty');
    expect(rules.validateText('ok'), isNull);
    expect(rules.validateText('x' * 1001), 'too_long');
  });

  test('maps closed-case sync failure', () {
    expect(rules.mapSyncFailure('P0001'), 'Failed: this case is closed');
    expect(rules.mapSyncFailure('P0002'), contains('Too many'));
  });
}
