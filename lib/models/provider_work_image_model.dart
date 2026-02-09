class ProviderWorkImage {
  final String id;
  final String providerId;
  final String imageUrl;
  final DateTime createdAt;

  ProviderWorkImage({
    required this.id,
    required this.providerId,
    required this.imageUrl,
    required this.createdAt,
  });

  // Convert JSON from Supabase to ProviderWorkImage object
  factory ProviderWorkImage.fromJson(Map<String, dynamic> json) {
    return ProviderWorkImage(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      imageUrl: json['image_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert ProviderWorkImage object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
