class ServiceProvider {
  final String id;
  final String userId;
  final String categoryId;
  final double pricePerHour;
  final String location;
  final double rating;
  final bool isAvailable;
  final String? profileImage;
  final DateTime createdAt;

  // These will be loaded separately if needed
  String? userName;
  String? categoryName;

  ServiceProvider({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.pricePerHour,
    required this.location,
    required this.rating,
    required this.isAvailable,
    this.profileImage,
    required this.createdAt,
    this.userName,
    this.categoryName,
  });

  // Convert JSON from Supabase to ServiceProvider object
  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      pricePerHour: (json['price_per_hour'] as num).toDouble(),
      location: json['location'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['is_available'] as bool? ?? true,
      profileImage: json['profile_image'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: json['user_name'] as String?,
      categoryName: json['category_name'] as String?,
    );
  }

  // Convert ServiceProvider object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'price_per_hour': pricePerHour,
      'location': location,
      'rating': rating,
      'is_available': isAvailable,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
    };
  }
}