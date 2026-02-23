import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../models/provider_work_image_model.dart';
import 'dart:io';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get user profile
  Future<Profile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String userId,
    required String fullName,
    String? phoneNumber,
    String? address,
    String? profileImage,
  }) async {
    try {
      await _client.from('profiles').update({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'address': address,
        'profile_image': profileImage,
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage({
    required String userId,
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      final fileExt = filePath.split('.').last;
      final fileName = '$userId/profile-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _client.storage.from('profile-images').upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _client.storage.from('profile-images').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Get provider work images
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
}