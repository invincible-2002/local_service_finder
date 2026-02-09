import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_model.dart';

class ReviewService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch reviews by provider ID
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

  // Create a new review
  Future<void> createReview({
    required String providerId,
    required String userId,
    required double rating,
  }) async {
    try {
      await _client.from('reviews').insert({
        'provider_id': providerId,
        'user_id': userId,
        'rating': rating,
      });
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  // Get average rating for a provider
  Future<double> getAverageRating(String providerId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('rating')
          .eq('provider_id', providerId);

      if (response.isEmpty) return 0.0;

      final ratings = (response as List).map((r) => (r['rating'] as num).toDouble());
      return ratings.reduce((a, b) => a + b) / ratings.length;
    } catch (e) {
      throw Exception('Failed to get average rating: $e');
    }
  }
}