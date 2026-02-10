class Category {
  final String id;
  final String name;
  final String? icon;  // Made nullable with ?
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.icon,  // Now optional
    required this.createdAt,
  });

  // Convert JSON from Supabase to Category object
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,  // Can be null now
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert Category object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
    };
  }
}