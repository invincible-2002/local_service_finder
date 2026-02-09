import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_model.dart';

class ServiceService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch services by provider ID
  Future<List<Service>> getServicesByProvider(String providerId) async {
    try {
      final response = await _client
          .from('services')
          .select()
          .eq('provider_id', providerId)
          .order('title', ascending: true);

      return (response as List)
          .map((json) => Service.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }

  // Search services by title
  Future<List<Service>> searchServices(String query) async {
    try {
      final response = await _client
          .from('services')
          .select()
          .ilike('title', '%$query%')
          .order('title', ascending: true);

      return (response as List)
          .map((json) => Service.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search services: $e');
    }
  }

  // Get service by ID
  Future<Service?> getServiceById(String serviceId) async {
    try {
      final response = await _client
          .from('services')
          .select()
          .eq('id', serviceId)
          .single();

      return Service.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch service: $e');
    }
  }
}