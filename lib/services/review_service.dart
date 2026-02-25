import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_model.dart';

class ReviewService {
  final SupabaseClient _client = Supabase.instance.client;

  // Create review
  Future<void> createReview({
    required String bookingId,
    required String userId,
    required String providerId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _client.from('reviews').insert({
        'booking_id': bookingId,
        'user_id': userId,
        'provider_id': providerId,
        'rating': rating,
        'comment': comment,
      });
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  // Get reviews by provider
  Future<List<Review>> getReviewsByProvider(String providerId) async {
    try {
      final response = await _client
          .from('reviews')
          .select()
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Review.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  // Get reviews by user
  Future<List<Review>> getReviewsByUser(String userId) async {
    try {
      final response = await _client
          .from('reviews')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Review.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }
}