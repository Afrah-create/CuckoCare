/// Whether a vet user may see a assistance request in inbox/map RPCs.
bool vetCanViewRequest({
  required String? assignedVetUserId,
  required String? requestedVetUserId,
  required String viewerUserId,
}) {
  if (assignedVetUserId != null) {
    return assignedVetUserId == viewerUserId;
  }
  if (requestedVetUserId != null) {
    return requestedVetUserId == viewerUserId;
  }
  return true;
}

bool vetInboxItemIsPendingForVet({
  required String status,
  required String? assignedVetUserId,
  required String? requestedVetUserId,
  required String vetUserId,
}) {
  if (status != 'submitted' && status != 'received') {
    return false;
  }
  if (assignedVetUserId != null) {
    return false;
  }
  return vetCanViewRequest(
    assignedVetUserId: assignedVetUserId,
    requestedVetUserId: requestedVetUserId,
    viewerUserId: vetUserId,
  );
}

bool vetInboxItemIsActiveForVet({
  required String status,
  required String? assignedVetUserId,
  required String vetUserId,
}) {
  if (status != 'accepted' && status != 'in_progress') {
    return false;
  }
  return assignedVetUserId == vetUserId;
}
