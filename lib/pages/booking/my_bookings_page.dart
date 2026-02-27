import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../reviews/leave_review_page.dart';


// Provider for user's bookings
// Provider for user's bookings (excluding cancelled)
final myBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  
  final bookingService = BookingService();
  final allBookings = await bookingService.getBookingsByUser(user.id);
  
  // Filter out cancelled bookings
  return allBookings.where((booking) => booking.status.toLowerCase() != 'cancelled').toList();
});
class MyBookingsPage extends ConsumerWidget {
  const MyBookingsPage({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: (){ Navigator.of(context).pop();},
        ),
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.invalidate(myBookingsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myBookingsProvider);
        },
        child: bookingsAsync.when(
          data: (bookings) {
            if (bookings.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _buildBookingCard(context, booking, ref);
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load bookings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(myBookingsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            const Text(
              'No Bookings Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your bookings will appear here once you make an appointment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home),
              label: const Text('Browse Services'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
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

 Widget _buildBookingCard(BuildContext context, Booking booking, WidgetRef ref) {
  final statusColor = _getStatusColor(booking.status);
  final statusIcon = _getStatusIcon(booking.status);

  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      children: [
        // Header with status
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking ID: ${booking.id.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Booking details
        Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.calendar_today,
                      'Date',
                      _formatDate(booking.serviceDate),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.access_time,
                      'Time',
                      _formatTime(booking.serviceDate),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Provider
              _buildInfoRow(
                Icons.person,
                'Provider ID',
                booking.providerId.substring(0, 8) + '...',
              ),

              const SizedBox(height: 15),

              // Actions + Review Section
              const SizedBox(height: 15),
              if (booking.status.toLowerCase() == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showCancelDialog(context, booking.id, ref);
                        },
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Contact provider feature coming soon!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Contact'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else if (booking.status.toLowerCase() == 'completed' && !(booking.reviewed ?? false))
                // Leave Review button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LeaveReviewPage(booking: booking),
                        ),
                      );

                      // Refresh if review was submitted
                      if (result == true) {
                        ref.invalidate(myBookingsProvider);
                      }
                    },
                    icon: const Icon(Icons.rate_review, size: 18),
                    label: const Text('Leave Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                )
              else if (booking.status.toLowerCase() == 'completed' && (booking.reviewed ?? false))
                // Reviewed badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700], size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Review Submitted',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String bookingId, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await BookingService().updateBookingStatus(
                  bookingId: bookingId,
                  status: 'cancelled',
                );

                ref.invalidate(myBookingsProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Booking cancelled successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to cancel: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}