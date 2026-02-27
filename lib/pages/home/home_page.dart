import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/category_model.dart';
import '../../models/service_provider_model.dart';
import '../../providers/provider_providers.dart';
import 'search_results_page.dart';
import '../provider/provider_list_page.dart';
import '../provider/provider_detail_page.dart';
import '../booking/booking_page.dart';
import '../booking/my_bookings_page.dart';
import '../profile/user_profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(query: query.trim()),
      ),
    );
  }

  void _onCategoryTap(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderListPage(category: category),
      ),
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
    
    final categoriesAsync = ref.watch(categoriesProvider);
    final providersAsync = ref.watch(topProvidersProvider);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Colors.blue[700]!,
            Colors.grey[50]!,
          ],
          stops: const [0.0, 0.3],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          color: Colors.blue[700],
          onRefresh: () async {
            ref.invalidate(categoriesProvider);
            ref.invalidate(topProvidersProvider);
          },
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
              scrollbars: false,
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModernHeader(userName),
                  const SizedBox(height: 20),
                  _buildSearchBarModern(),
                  const SizedBox(height: 30),
                  _buildQuickStats(),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Browse Services',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildCategorySection(categoriesAsync),
                  const SizedBox(height: 35),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.blue[700],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Top Rated Experts',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber[700], size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '4.8+',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildTopRatedSection(providersAsync),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
Widget _buildModernHeader(String userName) {
  final profileAsync = ref.watch(userProfileProvider);
  
  return FadeTransition(
    opacity: _fadeAnimation,
    child: Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello 👋',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                
              ],
            ),
          ),
          // Profile image with uploaded photo
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserProfilePage(),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: profileAsync.when(
                data: (profile) {
                  return CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: profile?.profileImage != null
                        ? NetworkImage(profile!.profileImage!)
                        : null,
                    child: profile?.profileImage == null
                        ? Icon(
                            Icons.person,
                            color: Colors.blue[700],
                            size: 32,
                          )
                        : null,
                  );
                },
                loading: () => CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue[700],
                    size: 32,
                  ),
                ),
                error: (_, __) => CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue[700],
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildSearchBarModern() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Hero(
        tag: 'search_bar',
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: _performSearch,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search for services...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.search, color: Colors.blue[700], size: 24),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.tune, color: Colors.blue[700], size: 20),
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.people_outline,
              count: '500+',
              label: 'Providers',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.star_outline,
              count: '4.8',
              label: 'Avg Rating',
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.verified_outlined,
              count: '100%',
              label: 'Verified',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color[700], size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color[700],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(AsyncValue<List<Category>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No categories available'),
            ),
          );
        }

        return SizedBox(
          height: 120,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: _buildModernCategoryCard(categories[index], index),
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 48),
              const SizedBox(height: 12),
              Text('Error: $error'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(categoriesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCategoryCard(Category category, int index) {
    final colors = [
      [const Color.fromARGB(255, 8, 214, 170)!, Colors.blue[600]!],
      [Colors.purple[400]!, Colors.purple[600]!],
      [Colors.orange[400]!, Colors.orange[600]!],
      [Colors.teal[400]!, Colors.teal[600]!],
      [Colors.pink[400]!, Colors.pink[600]!],
    ];
    
    final colorPair = colors[index % colors.length];
    
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
        width: 100,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colorPair,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorPair[1].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                getIconForCategory(category.name),
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRatedSection(AsyncValue<List<ServiceProvider>> providersAsync) {
    return providersAsync.when(
      data: (providers) {
        if (providers.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No service providers available'),
            ),
          );
        }

        return Column(
          children: providers.asMap().entries.map((entry) {
            int index = entry.key;
            ServiceProvider provider = entry.value;
            
            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 400 + (index * 100)),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: _buildModernServiceCard(provider, index),
            );
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 48),
              const SizedBox(height: 12),
              Text('Error: $error'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(topProvidersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernServiceCard(ServiceProvider provider, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProviderDetailPage(provider: provider),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Rank badge
            if (index < 3)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: index == 0
                          ? [Colors.amber[400]!, Colors.amber[600]!]
                          : index == 1
                              ? [Colors.grey[300]!, Colors.grey[400]!]
                              : [Colors.orange[300]!, Colors.orange[400]!],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Profile image with gradient border
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue[400]!, Colors.blue[700]!],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: provider.profileImage != null
                          ? NetworkImage(provider.profileImage!)
                          : null,
                      child: provider.profileImage == null
                          ? Icon(Icons.person, size: 40, color: Colors.grey[600])
                          : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // Provider info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          provider.userName ?? 'Unknown Provider',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            provider.categoryName ?? 'Service Provider',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber[700], size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    provider.rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[900],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      provider.location,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.payments, size: 14, color: Colors.green[600]),
                            const SizedBox(width: 4),
                            Text(
                              '৳${provider.pricePerHour.toStringAsFixed(0)}/hr',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Book button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue[400]!, Colors.blue[700]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingPage(provider: provider),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.white, size: 20),
                              SizedBox(height: 4),
                              Text(
                                'Book',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingContent() {
    return const MyBookingsPage();
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.calendar_today_rounded, 'Bookings', 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[700] : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[400],
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}