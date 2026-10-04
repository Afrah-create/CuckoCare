import 'package:cucocare/features/vet/domain/vet_case_workflow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('status progression actions', () {
    expect(
      vetCaseActionsFor(status: 'submitted', isAssignedToMe: false),
      [VetCaseAction.accept, VetCaseAction.decline],
    );
    expect(
      vetCaseActionsFor(status: 'accepted', isAssignedToMe: true),
      [VetCaseAction.startVisit],
    );
    expect(
      vetCaseActionsFor(status: 'in_progress', isAssignedToMe: true),
      [VetCaseAction.markComplete],
    );
    expect(vetStatusAfterAction(VetCaseAction.markComplete), 'completed');
  });

  test('in_progress label is not ambiguous pending', () {
    expect(
      vetRequestStatusLabel('in_progress'),
      'Visit in progress',
    );
  });
}
