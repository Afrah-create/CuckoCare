import 'package:cucocare/features/vet/domain/vet_request_visibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const me = 'vet-a';
  const other = 'vet-b';

  group('vetCanViewRequest', () {
    test('assigned to me', () {
      expect(
        vetCanViewRequest(
          assignedVetUserId: me,
          requestedVetUserId: other,
          viewerUserId: me,
        ),
        isTrue,
      );
    });

    test('assigned to other hides from me', () {
      expect(
        vetCanViewRequest(
          assignedVetUserId: other,
          requestedVetUserId: null,
          viewerUserId: me,
        ),
        isFalse,
      );
    });

    test('broadcast while unassigned', () {
      expect(
        vetCanViewRequest(
          assignedVetUserId: null,
          requestedVetUserId: null,
          viewerUserId: me,
        ),
        isTrue,
      );
    });

    test('directed to me while unassigned', () {
      expect(
        vetCanViewRequest(
          assignedVetUserId: null,
          requestedVetUserId: me,
          viewerUserId: me,
        ),
        isTrue,
      );
    });

    test('directed to other hides from me', () {
      expect(
        vetCanViewRequest(
          assignedVetUserId: null,
          requestedVetUserId: other,
          viewerUserId: me,
        ),
        isFalse,
      );
    });
  });

  group('inbox buckets', () {
    test('pending broadcast', () {
      expect(
        vetInboxItemIsPendingForVet(
          status: 'submitted',
          assignedVetUserId: null,
          requestedVetUserId: null,
          vetUserId: me,
        ),
        isTrue,
      );
    });

    test('active requires assignment to me', () {
      expect(
        vetInboxItemIsActiveForVet(
          status: 'accepted',
          assignedVetUserId: me,
          vetUserId: me,
        ),
        isTrue,
      );
      expect(
        vetInboxItemIsActiveForVet(
          status: 'accepted',
          assignedVetUserId: null,
          vetUserId: me,
        ),
        isFalse,
      );
    });
  });
}
