import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_provider_model.dart';

class ProviderService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch all service providers
  Future<List<ServiceProvider>> getServiceProviders() async {
    try {
      final response = await _client
          .from('service_providers')
          .select('''
            *,
            profiles!service_providers_user_id_fkey(full_name),
            categories!service_providers_category_id_fkey(name)
          ''')
          .eq('is_available', true)
          .order('rating', ascending: false);

      return (response as List).map((json) {
        final provider = ServiceProvider.fromJson(json);
        provider.userName = json['profiles']?['full_name'];
        provider.categoryName = json['categories']?['name'];
        return provider;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch service providers: $e');
    }
  }

  // Fetch service providers by category ID
  Future<List<ServiceProvider>> getProvidersByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('service_providers')
          .select('''
            *,
            profiles!service_providers_user_id_fkey(full_name),
            categories!service_providers_category_id_fkey(name)
          ''')
          .eq('category_id', categoryId)
          .eq('is_available', true)
          .order('rating', ascending: false);

      return (response as List).map((json) {
        final provider = ServiceProvider.fromJson(json);
        provider.userName = json['profiles']?['full_name'];
        provider.categoryName = json['categories']?['name'];
        return provider;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch providers by category: $e');
    }
  }

  // Search service providers
  Future<List<ServiceProvider>> searchProviders(String query) async {
    try {
      final response = await _client
          .from('service_providers')
          .select('''
            *,
            profiles!service_providers_user_id_fkey(full_name),
            categories!service_providers_category_id_fkey(name)
          ''')
          .or('location.ilike.%$query%')
          .eq('is_available', true)
          .order('rating', ascending: false);

      return (response as List).map((json) {
        final provider = ServiceProvider.fromJson(json);
        provider.userName = json['profiles']?['full_name'];
        provider.categoryName = json['categories']?['name'];
        return provider;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search providers: $e');
    }
  }

  // Get provider by ID
  Future<ServiceProvider?> getProviderById(String providerId) async {
    try {
      final response = await _client
          .from('service_providers')
          .select('''
            *,
            profiles!service_providers_user_id_fkey(full_name),
            categories!service_providers_category_id_fkey(name)
          ''')
          .eq('id', providerId)
          .single();

      final provider = ServiceProvider.fromJson(response);
      provider.userName = response['profiles']?['full_name'];
      provider.categoryName = response['categories']?['name'];
      return provider;
    } catch (e) {
      throw Exception('Failed to fetch provider: $e');
    }
  }
}
