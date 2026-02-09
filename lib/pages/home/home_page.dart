import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/category_service.dart';
import '../../services/provider_service.dart';
import '../../models/category_model.dart';
import '../../models/service_provider_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  // Services
  final CategoryService _categoryService = CategoryService();
  final ProviderService _providerService = ProviderService();
  
  // Data lists
  List<Category> _categories = [];
  List<ServiceProvider> _topProviders = [];
  
  // Loading states
  bool _isLoadingCategories = true;
  bool _isLoadingProviders = true;
  
  // Search controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load categories and providers from Supabase
  Future<void> _loadData() async {
    await Future.wait([
      _loadCategories(),
      _loadTopProviders(),
    ]);
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  Future<void> _loadTopProviders() async {
    try {
      final providers = await _providerService.getServiceProviders();
      setState(() {
        _topProviders = providers;
        _isLoadingProviders = false;
      });
    } catch (e) {
      setState(() => _isLoadingProviders = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load providers: $e')),
        );
      }
    }
  }

  // Search functionality
  void _performSearch(String query) {
    if (query.isEmpty) return;
    
    // TODO: Navigate to search results page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for: $query')),
    );
  }

  // Handle category click
  void _onCategoryTap(Category category) {
    // TODO: Navigate to provider list page by category
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected category: ${category.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _currentIndex == 0 ? _buildHomeContent() : _buildBookingContent(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeContent() {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.email?.split('@')[0] ?? 'User';
    
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with profile
                _buildHeader(userName),
                const SizedBox(height: 25),
                
                // Search bar
                _buildSearchBar(),
                const SizedBox(height: 30),
                
                // Service Categories
                const Text(
                  'Service Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                _buildCategorySection(),
                const SizedBox(height: 30),
                
                // Top Rated Services
                const Text(
                  'Top Rated Services',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                _buildTopRatedSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome,',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue[600],
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: _performSearch,
        decoration: InputDecoration(
          hintText: 'Search services or categories...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildCategorySection() {
    if (_isLoadingCategories) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No categories available'),
        ),
      );
    }

    // Horizontal scrollable categories
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(_categories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    // Map category names to icons
    IconData getIconForCategory(String name) {
      switch (name.toLowerCase()) {
        case 'electrician':
          return Icons.bolt;
        case 'mechanic':
          return Icons.build;
        case 'plumber':
          return Icons.water_drop;
        case 'home tutor':
        case 'tutor':
          return Icons.school;
        case 'cleaner':
        case 'cleaning':
          return Icons.cleaning_services;
        case 'painter':
          return Icons.format_paint;
        case 'carpenter':
          return Icons.carpenter;
        default:
          return Icons.work;
      }
    }

    return GestureDetector(
      onTap: () => _onCategoryTap(category),
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              getIconForCategory(category.name),
              size: 32,
              color: Colors.black87,
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRatedSection() {
    if (_isLoadingProviders) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_topProviders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No service providers available'),
        ),
      );
    }

    return Column(
      children: _topProviders.map((provider) {
        return _buildServiceCard(provider);
      }).toList(),
    );
  }

  Widget _buildServiceCard(ServiceProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            backgroundImage: provider.profileImage != null
                ? NetworkImage(provider.profileImage!)
                : null,
            child: provider.profileImage == null
                ? Icon(Icons.person, size: 35, color: Colors.grey[600])
                : null,
          ),
          const SizedBox(width: 15),
          
          // Service Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.userName ?? 'Unknown Provider',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  provider.categoryName ?? 'Service Provider',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      provider.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        provider.location,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '৳${provider.pricePerHour.toStringAsFixed(0)}/hour',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          
          // Book Button
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to provider detail page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Booking ${provider.userName}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Book',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingContent() {
    return const Center(
      child: Text(
        'Booking Page',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Booking',
          ),
        ],
      ),
    );
  }
}