class Review {
  final String id;
  final String providerId;
  final String userId;
  final double rating;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.providerId,
    required this.userId,
    required this.rating,
    required this.createdAt,
  });

  // Convert JSON from Supabase to Review object
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      userId: json['user_id'] as String,
      rating: (json['rating'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert Review object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'user_id': userId,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}