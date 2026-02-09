import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../models/provider_work_image_model.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch user profile by user ID
  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Fetch provider work images
  Future<List<ProviderWorkImage>> getProviderWorkImages(String providerId) async {
    try {
      final response = await _client
          .from('provider_work_images')
          .select()
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProviderWorkImage.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch work images: $e');
    }
  }

  // Add provider work image
  Future<void> addWorkImage({
    required String providerId,
    required String imageUrl,
  }) async {
    try {
      await _client.from('provider_work_images').insert({
        'provider_id': providerId,
        'image_url': imageUrl,
      });
    } catch (e) {
      throw Exception('Failed to add work image: $e');
    }
  }
}