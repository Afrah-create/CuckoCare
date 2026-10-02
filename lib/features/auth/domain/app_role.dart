/// Application role for RBAC (stored on `profiles.app_role` and auth snapshot).
enum AppRole {
  farmer,
  vet;

  String get wireValue => switch (this) {
        AppRole.farmer => 'farmer',
        AppRole.vet => 'vet',
      };

  String get label => switch (this) {
        AppRole.farmer => 'Farmer',
        AppRole.vet => 'Veterinary professional',
      };

  /// Default home route after sign-in for this role.
  String get homeLocation => switch (this) {
        AppRole.farmer => '/today',
        AppRole.vet => '/vet',
      };

  static AppRole fromWire(String? value) {
    return switch (value) {
      'vet' => AppRole.vet,
      _ => AppRole.farmer,
    };
  }
}

bool isFarmerShellPath(String location) {
  if (isVetShellPath(location)) {
    return false;
  }
  return location.startsWith('/today') ||
      location.startsWith('/feed') ||
      location.startsWith('/records') ||
      location.startsWith('/more');
}

/// Farmer-only routes outside the tab shell (batches, farm profile, etc.).
bool isFarmerOnlyAppPath(String location) {
  if (isVetShellPath(location)) {
    return false;
  }
  return isFarmerShellPath(location) ||
      location.startsWith('/batches') ||
      location.startsWith('/more/farm');
}

bool isVetShellPath(String location) {
  return location.startsWith('/vet');
}
