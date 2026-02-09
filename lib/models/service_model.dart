class Service {
  final String id;
  final String providerId;
  final String title;
  final double price;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.providerId,
    required this.title,
    required this.price,
    required this.createdAt,
  });

  // Convert JSON from Supabase to Service object
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert Service object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'title': title,
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }
}