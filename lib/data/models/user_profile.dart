class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
    required this.memberSince,
    required this.orderCount,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String city;
  final String memberSince;
  final int orderCount;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final first = parts.first;
      return first.isEmpty ? '?' : first[0].toUpperCase();
    }
    final first = parts.first;
    final last = parts.last;
    if (first.isEmpty || last.isEmpty) return '?';
    return '${first[0]}${last[0]}'.toUpperCase();
  }
}
