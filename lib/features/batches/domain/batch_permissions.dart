enum FarmRole {
  owner,
  manager,
  worker,
  viewer;

  static FarmRole fromStorage(String? value) => switch (value) {
    'manager' => FarmRole.manager,
    'worker' => FarmRole.worker,
    'viewer' => FarmRole.viewer,
    _ => FarmRole.owner,
  };
}

/// What a farm member may do in the batch module.
class BatchPermissions {
  const BatchPermissions(this.role);

  final FarmRole role;

  static const viewerReason = 'You have view-only access to this farm.';
  static const workerReason = 'Only the farm owner or a manager can do this.';

  bool get canRecordLosses => role != FarmRole.viewer;

  bool get canManageBatch => role == FarmRole.owner || role == FarmRole.manager;

  /// Why an action is unavailable, or null when it is allowed.
  String? get recordLossBlockedReason => canRecordLosses ? null : viewerReason;

  String? get manageBlockedReason => canManageBatch
      ? null
      : role == FarmRole.viewer
      ? viewerReason
      : workerReason;
}
