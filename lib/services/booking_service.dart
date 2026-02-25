import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class BookingService {
  final SupabaseClient _client = Supabase.instance.client;

  // Create a new booking
  Future<void> createBooking({
    required String userId,
    required String providerId,
    required DateTime serviceDate,
  }) async {
    try {
      await _client.from('bookings').insert({
        'user_id': userId,
        'provider_id': providerId,
        'service_date': serviceDate.toIso8601String(),
        'status': 'pending',
      });
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Fetch bookings by user ID
  Future<List<Booking>> getBookingsByUser(String userId) async {
    try {
      final response = await _client
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('service_date', ascending: false);

      return (response as List)
          .map((json) => Booking.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  // Fetch bookings by provider ID
  Future<List<Booking>> getBookingsByProvider(String providerId) async {
    try {
      final response = await _client
          .from('bookings')
          .select()
          .eq('provider_id', providerId)
          .order('service_date', ascending: false);

      return (response as List)
          .map((json) => Booking.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch provider bookings: $e');
    }
  }

  // Update booking status
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      await _client
          .from('bookings')
          .update({'status': status})
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }
  // Mark booking as reviewed
Future<void> markBookingAsReviewed(String bookingId) async {
  try {
    await _client
        .from('bookings')
        .update({'reviewed': true})
        .eq('id', bookingId);
  } catch (e) {
    throw Exception('Failed to mark booking as reviewed: $e');
  }
}
}
