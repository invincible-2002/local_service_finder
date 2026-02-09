import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

class CategoryService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Search categories by name
  Future<List<Category>> searchCategories(String query) async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .ilike('name', '%$query%')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search categories: $e');
    }
  }

  // Get category by ID
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('id', categoryId)
          .single();

      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }
}