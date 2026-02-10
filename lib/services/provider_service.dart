import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_provider_model.dart';

class ProviderService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch all service providers (no joins - simpler)
  Future<List<ServiceProvider>> getServiceProviders() async {
    print('🔍 ProviderService: Fetching providers...');
    
    try {
      final response = await _client
          .from('service_providers')
          .select()
          .eq('is_available', true)
          .order('rating', ascending: false);

      print('📦 Providers response: ${(response as List).length} providers');

      List<ServiceProvider> providers = [];
      
      for (var json in response as List) {
        final provider = ServiceProvider.fromJson(json);
        
        // Fetch user name separately
        try {
          final profileResponse = await _client
              .from('profiles')
              .select('full_name')
              .eq('id', provider.userId)
              .maybeSingle();  // Changed to maybeSingle to handle null
          
          provider.userName = profileResponse?['full_name'] ?? 'Unknown';
        } catch (e) {
          print('⚠️ Failed to fetch profile for ${provider.userId}: $e');
          provider.userName = 'Unknown';
        }
        
        // Fetch category name separately
        try {
          final categoryResponse = await _client
              .from('categories')
              .select('name')
              .eq('id', provider.categoryId)
              .maybeSingle();  // Changed to maybeSingle to handle null
          
          provider.categoryName = categoryResponse?['name'] ?? 'Unknown';
        } catch (e) {
          print('⚠️ Failed to fetch category for ${provider.categoryId}: $e');
          provider.categoryName = 'Unknown';
        }
        
        providers.add(provider);
      }
      
      print('✅ Successfully loaded ${providers.length} providers');
      return providers;
    } catch (e, stackTrace) {
      print('❌ Error fetching providers: $e');
      print('📍 Stack trace: $stackTrace');
      throw Exception('Failed to fetch service providers: $e');
    }
  }

  // Fetch service providers by category ID
  Future<List<ServiceProvider>> getProvidersByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('service_providers')
          .select()
          .eq('category_id', categoryId)
          .eq('is_available', true)
          .order('rating', ascending: false);

      List<ServiceProvider> providers = [];
      
      for (var json in response as List) {
        final provider = ServiceProvider.fromJson(json);
        
        // Fetch user name separately
        try {
          final profileResponse = await _client
              .from('profiles')
              .select('full_name')
              .eq('id', provider.userId)
              .maybeSingle();
          provider.userName = profileResponse?['full_name'] ?? 'Unknown';
        } catch (e) {
          provider.userName = 'Unknown';
        }
        
        // Fetch category name separately
        try {
          final categoryResponse = await _client
              .from('categories')
              .select('name')
              .eq('id', provider.categoryId)
              .maybeSingle();
          provider.categoryName = categoryResponse?['name'] ?? 'Unknown';
        } catch (e) {
          provider.categoryName = 'Unknown';
        }
        
        providers.add(provider);
      }
      
      return providers;
    } catch (e) {
      throw Exception('Failed to fetch providers by category: $e');
    }
  }

  // Search service providers
  Future<List<ServiceProvider>> searchProviders(String query) async {
    try {
      final response = await _client
          .from('service_providers')
          .select()
          .ilike('location', '%$query%')
          .eq('is_available', true)
          .order('rating', ascending: false);

      List<ServiceProvider> providers = [];
      
      for (var json in response as List) {
        final provider = ServiceProvider.fromJson(json);
        
        try {
          final profileResponse = await _client
              .from('profiles')
              .select('full_name')
              .eq('id', provider.userId)
              .maybeSingle();
          provider.userName = profileResponse?['full_name'] ?? 'Unknown';
        } catch (e) {
          provider.userName = 'Unknown';
        }
        
        try {
          final categoryResponse = await _client
              .from('categories')
              .select('name')
              .eq('id', provider.categoryId)
              .maybeSingle();
          provider.categoryName = categoryResponse?['name'] ?? 'Unknown';
        } catch (e) {
          provider.categoryName = 'Unknown';
        }
        
        providers.add(provider);
      }
      
      return providers;
    } catch (e) {
      throw Exception('Failed to search providers: $e');
    }
  }

  // Get provider by ID
  Future<ServiceProvider?> getProviderById(String providerId) async {
    try {
      final response = await _client
          .from('service_providers')
          .select()
          .eq('id', providerId)
          .maybeSingle();

      if (response == null) return null;

      final provider = ServiceProvider.fromJson(response);
      
      try {
        final profileResponse = await _client
            .from('profiles')
            .select('full_name')
            .eq('id', provider.userId)
            .maybeSingle();
        provider.userName = profileResponse?['full_name'] ?? 'Unknown';
      } catch (e) {
        provider.userName = 'Unknown';
      }
      
      try {
        final categoryResponse = await _client
            .from('categories')
            .select('name')
            .eq('id', provider.categoryId)
            .maybeSingle();
        provider.categoryName = categoryResponse?['name'] ?? 'Unknown';
      } catch (e) {
        provider.categoryName = 'Unknown';
      }
      
      return provider;
    } catch (e) {
      throw Exception('Failed to fetch provider: $e');
    }
  }
}