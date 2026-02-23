import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/category_service.dart';
import '../services/provider_service.dart';
import '../services/service_service.dart';
import '../services/review_service.dart';
import '../services/profile_service.dart';
import '../models/category_model.dart';
import '../models/service_provider_model.dart';
import '../models/service_model.dart';
import '../models/review_model.dart';
import '../models/provider_work_image_model.dart';
import '../models/profile_model.dart';

// ==================== SERVICE PROVIDERS ====================

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

final providerServiceProvider = Provider<ProviderService>((ref) {
  return ProviderService();
});

final serviceServiceProvider = Provider<ServiceService>((ref) {
  return ServiceService();
});

final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

// ==================== DATA PROVIDERS ====================

// All Categories
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final service = ref.read(categoryServiceProvider);
  return await service.getCategories();
});

// All Service Providers (Top Rated)
final topProvidersProvider = FutureProvider<List<ServiceProvider>>((ref) async {
  final service = ref.read(providerServiceProvider);
  final providers = await service.getServiceProviders();
  
  // Remove duplicates based on user_id
  final Map<String, ServiceProvider> uniqueProviders = {};
  for (var provider in providers) {
    if (!uniqueProviders.containsKey(provider.userId)) {
      uniqueProviders[provider.userId] = provider;
    }
  }
  
  return uniqueProviders.values.toList();
});

// Providers by Category
final providersByCategoryProvider = FutureProvider.family<List<ServiceProvider>, String>(
  (ref, categoryId) async {
    final service = ref.read(providerServiceProvider);
    return await service.getProvidersByCategory(categoryId);
  },
);

// Search Categories
final searchCategoriesProvider = FutureProvider.family<List<Category>, String>(
  (ref, query) async {
    final service = ref.read(categoryServiceProvider);
    return await service.searchCategories(query);
  },
);

// Search Providers
final searchProvidersProvider = FutureProvider.family<List<ServiceProvider>, String>(
  (ref, query) async {
    final service = ref.read(providerServiceProvider);
    return await service.searchProviders(query);
  },
);

// Provider Details
final providerDetailsProvider = FutureProvider.family<ServiceProvider?, String>(
  (ref, providerId) async {
    final service = ref.read(providerServiceProvider);
    return await service.getProviderById(providerId);
  },
);

// Provider Services
final providerServicesProvider = FutureProvider.family<List<Service>, String>(
  (ref, providerId) async {
    final service = ref.read(serviceServiceProvider);
    return await service.getServicesByProvider(providerId);
  },
);

// Provider Reviews
final providerReviewsProvider = FutureProvider.family<List<Review>, String>(
  (ref, providerId) async {
    final service = ref.read(reviewServiceProvider);
    return await service.getReviewsByProvider(providerId);
  },
);

// Provider Work Images
final providerWorkImagesProvider = FutureProvider.family<List<ProviderWorkImage>, String>(
  (ref, providerId) async {
    final service = ref.read(profileServiceProvider);
    return await service.getProviderWorkImages(providerId);
  },
);
// User Profile Provider
final userProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  
  final profileService = ProfileService();
  return await profileService.getUserProfile(user.id);
}
);