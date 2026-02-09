class Profile {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
  });

  // Convert JSON from Supabase to Profile object
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert Profile object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}