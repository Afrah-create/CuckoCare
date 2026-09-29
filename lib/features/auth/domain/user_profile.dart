class UserProfile {
  const UserProfile({
    this.email,
    this.phone,
    this.isDemo = false,
  });

  final String? email;
  final String? phone;
  final bool isDemo;

  String get displayName {
    if (email != null && email!.isNotEmpty) {
      return email!.split('@').first;
    }
    if (phone != null && phone!.isNotEmpty) {
      return phone!;
    }
    return 'Farmer';
  }

  String get initials {
    final source = email ?? phone ?? 'F';
    final parts = source.trim().split(RegExp(r'[\s@._-]+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (source.isNotEmpty) {
      return source[0].toUpperCase();
    }
    return '?';
  }
}
