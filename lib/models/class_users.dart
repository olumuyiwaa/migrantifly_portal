// Dart
class User {
  final String id;
  final String createdAt;
  final String image;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final String countryLocated;
  final String fullAddress;
  final String representedCountry;
  final List<String> countries;
  final List<String> mediaFiles;
  final List<String> bookmarkedEvents;

  User({
    required this.id,
    required this.createdAt,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.countries,
    required this.mediaFiles,
    required this.bookmarkedEvents,
    required this.representedCountry,
    required this.countryLocated,
    required this.fullAddress,
    required this.image,
  });

  // Helper to safely cast any list to List<String>
  static List<String> _toStringList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => e == null ? '' : e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final profile = (json['profile'] is Map<String, dynamic>)
        ? json['profile'] as Map<String, dynamic>
        : null;
    final address = (profile != null && profile['address'] is Map<String, dynamic>)
        ? profile['address'] as Map<String, dynamic>
        : null;

    // Compose full name from nested profile if needed
    final firstName = (profile?['firstName'] ?? '').toString();
    final lastName = (profile?['lastName'] ?? '').toString();
    final composedFullName = [firstName, lastName]
        .where((s) => s.trim().isNotEmpty)
        .join(' ')
        .trim();

    return User(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? json['created_at'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      fullName: (json['full_name'] ?? composedFullName).toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber:
      (json['phone_number'] ?? profile?['phone'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),

      // Lists (keep old keys if your legacy payloads are still used)
      countries: _toStringList(json['interests'] ?? json['countries']),
      mediaFiles: _toStringList(json['mediaFiles']),
      bookmarkedEvents: _toStringList(json['bookmarkedEvents']),

      // Derive from the new structure where possible, fallback to legacy keys
      representedCountry: (json['countryRepresented'] ??
          profile?['nationality'] ??
          address?['country'] ??
          '')
          .toString(),
      countryLocated: (json['countryLocated'] ?? address?['country'] ?? '')
          .toString(),
      fullAddress: ("${address?['street']}, ${address?['city']}, ${address?['state']}, ${address?['country']}, ${address?['postalCode']}" ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'createdAt': createdAt,
      'image': image,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'interests': countries,
      'mediaFiles': mediaFiles,
      'bookmarkedEvents': bookmarkedEvents,
      'countryRepresented': representedCountry,
      'countryLocated': countryLocated,
      'fullAddress': fullAddress,
    };
  }

  factory User.empty() {
    return User(
      id: '',
      createdAt: '',
      image: '',
      fullName: '',
      email: '',
      phoneNumber: '',
      role: '',
      countries: const [],
      mediaFiles: const [],
      bookmarkedEvents: const [],
      representedCountry: '',
      countryLocated: '',
      fullAddress: '',
    );
  }

  // Convenience: parse an envelope like { "users": [ ... ] }
  static List<User> listFromUsersEnvelope(Map<String, dynamic> json) {
    final list = (json['users'] is List) ? json['users'] as List : const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((u) => User.fromJson(u))
        .toList();
  }
}