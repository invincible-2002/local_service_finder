class Booking {
  final String id;
  final String userId;
  final String providerId;
  final DateTime serviceDate;
  final String status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceDate,
    required this.status,
    required this.createdAt,
  });

  // Convert JSON from Supabase to Booking object
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      providerId: json['provider_id'] as String,
      serviceDate: DateTime.parse(json['service_date'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert Booking object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'provider_id': providerId,
      'service_date': serviceDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}