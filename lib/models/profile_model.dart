class Profile {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? profileImage;
  final String role;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.address,
    this.profileImage,
    required this.role,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      profileImage: json['profile_image'] as String?,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'profile_image': profileImage,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}