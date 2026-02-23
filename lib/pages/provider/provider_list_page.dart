import 'provider_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../services/provider_service.dart';
import '../../models/service_provider_model.dart';
import '../../models/category_model.dart';
import '../booking/booking_page.dart';

class ProviderListPage extends StatefulWidget {
  final Category category;

  const ProviderListPage({super.key, required this.category});

  @override
  State<ProviderListPage> createState() => _ProviderListPageState();
}

class _ProviderListPageState extends State<ProviderListPage> {
  final ProviderService _providerService = ProviderService();
  
  List<ServiceProvider> _providers = [];
  bool _isLoading = true;
  String _sortBy = 'rating'; // rating, price_low, price_high

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() => _isLoading = true);

    try {
      final providers = await _providerService.getProvidersByCategory(widget.category.id);
      
      setState(() {
        _providers = providers;
        _isLoading = false;
      });
      
      _sortProviders();
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load providers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sortProviders() {
    setState(() {
      if (_sortBy == 'rating') {
        _providers.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (_sortBy == 'price_low') {
        _providers.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
      } else if (_sortBy == 'price_high') {
        _providers.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
      }
    });
  }

  IconData _getCategoryIcon() {
    switch (widget.category.name.toLowerCase()) {
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

  Color _getCategoryColor() {
    switch (widget.category.name.toLowerCase()) {
      case 'electrician':
        return Colors.amber;
      case 'mechanic':
        return Colors.blue;
      case 'plumber':
        return Colors.cyan;
      case 'home tutor':
      case 'tutor':
        return Colors.purple;
      case 'cleaner':
      case 'cleaning':
        return Colors.green;
      case 'painter':
        return Colors.orange;
      case 'carpenter':
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Beautiful App Bar with gradient
          _buildSliverAppBar(),
          
          // Sort and Filter Bar
          SliverToBoxAdapter(
            child: _buildSortFilterBar(),
          ),
          
          // Provider Count
          SliverToBoxAdapter(
            child: _buildProviderCount(),
          ),
          
          // Provider List
          _isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _getCategoryColor(),
                    ),
                  ),
                )
              : _providers.isEmpty
                  ? SliverFillRemaining(
                      child: _buildEmptyState(),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _buildProviderCard(_providers[index], index);
                          },
                          childCount: _providers.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final categoryColor = _getCategoryColor();
    
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: categoryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.category.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                categoryColor,
                categoryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              _getCategoryIcon(),
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortFilterBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.sort, color: Colors.grey[600], size: 20),
          const SizedBox(width: 10),
          Text(
            'Sort by:',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: _getCategoryColor()),
                style: TextStyle(
                  color: _getCategoryColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'rating',
                    child: Text('Highest Rated'),
                  ),
                  DropdownMenuItem(
                    value: 'price_low',
                    child: Text('Price: Low to High'),
                  ),
                  DropdownMenuItem(
                    value: 'price_high',
                    child: Text('Price: High to Low'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _sortProviders();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        '${_providers.length} ${_providers.length == 1 ? 'Provider' : 'Providers'} Available',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProviderCard(ServiceProvider provider, int index) {
    final categoryColor = _getCategoryColor();
    
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ProviderDetailPage(provider: provider),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image with Badge
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: categoryColor,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: provider.profileImage != null
                                  ? NetworkImage(provider.profileImage!)
                                  : null,
                              child: provider.profileImage == null
                                  ? Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey[400],
                                    )
                                  : null,
                            ),
                          ),
                          if (provider.isAvailable)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      
                      // Provider Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.userName ?? 'Unknown Provider',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    provider.categoryName ?? 'Service Provider',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: categoryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                // Rating
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        provider.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Price Tag
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '৳${provider.pricePerHour.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: categoryColor,
                            ),
                          ),
                          Text(
                            'per hour',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          provider.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => ProviderDetailPage(provider: provider),
                            ));
                          },
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('View Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: categoryColor,
                            side: BorderSide(color: categoryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => BookingPage(provider: provider),
                            ));
                          },
                          
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text('Book Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: categoryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(),
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'No ${widget.category.name}s Available',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'There are currently no service providers in this category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getCategoryColor(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
