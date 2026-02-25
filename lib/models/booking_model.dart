class Booking {
  final String id;
  final String userId;
  final String providerId;
  final DateTime serviceDate;
  final String status;
  final bool? reviewed;  // ← ADD THIS
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceDate,
    required this.status,
    this.reviewed,  // ← ADD THIS
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      providerId: json['provider_id'] as String,
      serviceDate: DateTime.parse(json['service_date'] as String),
      status: json['status'] as String,
      reviewed: json['reviewed'] as bool?,  // ← ADD THIS
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'provider_id': providerId,
      'service_date': serviceDate.toIso8601String(),
      'status': status,
      'reviewed': reviewed,  // ← ADD THIS
      'created_at': createdAt.toIso8601String(),
    };
  }
}