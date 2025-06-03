import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:guidini/constants/colors.dart';
import 'package:guidini/services/auth_service.dart';
import 'package:guidini/config/app_config.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<Booking> bookings = [];
  List<Booking> filteredBookings = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBookings();
    _searchController.addListener(_filterBookings);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchBookings() async {
    setState(() => isLoading = true);

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.apiHost}/api/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📋 Bookings response: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];

        final parsedBookings =
            data.map((json) => Booking.fromJson(json)).toList();

        setState(() {
          bookings = parsedBookings;
          filteredBookings = parsedBookings;
          isLoading = false;
        });

        print('✅ Successfully loaded ${bookings.length} bookings');
      } else {
        print('❌ Error fetching bookings: ${response.statusCode}');
        setState(() {
          bookings = [];
          filteredBookings = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('💥 Error fetching bookings: $e');
      setState(() {
        bookings = [];
        filteredBookings = [];
        isLoading = false;
      });
    }
  }

  void _filterBookings() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredBookings = bookings.where((booking) {
        return booking.tour.title.toLowerCase().contains(query) ||
            booking.bookingReference.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _cancelBooking(Booking booking) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content:
            Text('Are you sure you want to cancel "${booking.tour.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.apiHost}/api/bookings/${booking.id}/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled successfully')),
        );
        fetchBookings(); // Refresh the list
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(errorData['message'] ?? 'Failed to cancel booking')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error cancelling booking')),
      );
    }
  }

  Future<void> _contactGuide(Booking booking) async {
    // Placeholder for contact guide functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact guide feature coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    'My bookings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'InstrumentSans',
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.gray050,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: AppColors.grayText),
                    prefixIcon: Icon(Icons.search, color: AppColors.grayText),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bookings List
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'lib/assets/animations/loading_animation.json',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Loading bookings...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : filteredBookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.bookmark_border,
                                size: 64,
                                color: AppColors.grayText,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No bookings found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'InstrumentSans',
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Your tour bookings will appear here',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.grayText,
                                  fontFamily: 'InstrumentSans',
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredBookings.length,
                          itemBuilder: (context, index) {
                            final booking = filteredBookings[index];
                            return BookingCard(
                              booking: booking,
                              onCancel: () => _cancelBooking(booking),
                              onContactGuide: () => _contactGuide(booking),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingCard extends StatefulWidget {
  final Booking booking;
  final VoidCallback onCancel;
  final VoidCallback onContactGuide;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onCancel,
    required this.onContactGuide,
  });

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool isExpanded = true; // Start expanded by default

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and Date Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(widget.booking.bookedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                        fontFamily: 'InstrumentSans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    _buildStatusBadge(widget.booking.status),
                  ],
                ),

                const SizedBox(height: 16),

                // Tour Title
                Text(
                  widget.booking.tour.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                    fontFamily: 'InstrumentSans',
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 8),

                // Location
                Text(
                  widget.booking.tour.location.label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    fontFamily: 'InstrumentSans',
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 20),

                // Guide Info
                const Text(
                  'Guided by',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontFamily: 'InstrumentSans',
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    // Guide Avatar
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF7C2D12),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.booking.tour.guide.user.firstName} ${widget.booking.tour.guide.user.lastName}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        fontFamily: 'InstrumentSans',
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, size: 16, color: Color(0xFFFBBF24)),
                    const SizedBox(width: 4),
                    Text(
                      widget.booking.tour.guide.rating,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF111827),
                        fontFamily: 'InstrumentSans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const SizedBox(width: 32), // Align with guide name
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.booking.tour.guide.user.city.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontFamily: 'InstrumentSans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '\$${double.parse(widget.booking.totalPrice).toInt()}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        fontFamily: 'InstrumentSans',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons Section - Only show when expanded
          if (isExpanded) ...[
            // For confirmed bookings - show action buttons
            if (widget.booking.status == 'confirmed')
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    // View Details Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to booking details
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C2D12),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.percent, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'View details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'InstrumentSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Contact Guide Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: widget.onContactGuide,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF374151),
                          backgroundColor: const Color(0xFFF9FAFB),
                          side: const BorderSide(
                              color: Color(0xFFE5E7EB), width: 1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Contact guide',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'InstrumentSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],

          // Expand/Collapse Button
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF9CA3AF),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'confirmed':
        backgroundColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        displayText = 'Confirmed';
        icon = Icons.check;
        break;
      case 'pending':
        backgroundColor = const Color(0xFFDEF7FF);
        textColor = const Color(0xFF0369A1);
        displayText = 'Waiting for guide\'s confirmation';
        icon = Icons.access_time;
        break;
      case 'cancelled':
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        displayText = 'Cancelled';
        icon = Icons.close;
        break;
      case 'completed':
        backgroundColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF7C3AED);
        displayText = 'Completed';
        icon = Icons.check_circle;
        break;
      default:
        backgroundColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        displayText = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w600,
              fontFamily: 'InstrumentSans',
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

// Updated Booking Model to match new API structure
class Booking {
  final int id;
  final String bookingReference;
  final String bookedDate;
  final int groupSize;
  final String totalPrice;
  final String status;
  final Tour tour;
  final String createdAt;
  final String updatedAt;

  Booking({
    required this.id,
    required this.bookingReference,
    required this.bookedDate,
    required this.groupSize,
    required this.totalPrice,
    required this.status,
    required this.tour,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      bookingReference: json['bookingReference'],
      bookedDate: json['bookedDate'],
      groupSize: json['groupSize'],
      totalPrice: json['totalPrice'],
      status: json['status'],
      tour: Tour.fromJson(json['tour']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class Tour {
  final int id;
  final int guideId;
  final int locationId;
  final int cityId;
  final int bookingCount;
  final int activityCount;
  final String title;
  final String description;
  final String price;
  final int duration;
  final int maxGroupSize;
  final String availabilityStatus;
  final bool isTransportIncluded;
  final bool isFoodIncluded;
  final String createdAt;
  final String updatedAt;
  final int rating;
  final Guide guide;
  final Location location;

  Tour({
    required this.id,
    required this.guideId,
    required this.locationId,
    required this.cityId,
    required this.bookingCount,
    required this.activityCount,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.maxGroupSize,
    required this.availabilityStatus,
    required this.isTransportIncluded,
    required this.isFoodIncluded,
    required this.createdAt,
    required this.updatedAt,
    required this.rating,
    required this.guide,
    required this.location,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      guideId: json['guideId'],
      locationId: json['locationId'],
      cityId: json['cityId'],
      bookingCount: json['bookingCount'],
      activityCount: json['activityCount'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      duration: json['duration'],
      maxGroupSize: json['maxGroupSize'],
      availabilityStatus: json['availabilityStatus'],
      isTransportIncluded: json['isTransportIncluded'],
      isFoodIncluded: json['isFoodIncluded'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      rating: json['rating'],
      guide: Guide.fromJson(json['guide']),
      location: Location.fromJson(json['location']),
    );
  }
}

class Guide {
  final int id;
  final int userId;
  final List<String> languages;
  final bool isVerified;
  final String rating;
  final String biography;
  final String createdAt;
  final String updatedAt;
  final User user;

  Guide({
    required this.id,
    required this.userId,
    required this.languages,
    required this.isVerified,
    required this.rating,
    required this.biography,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: json['id'],
      userId: json['userId'],
      languages: List<String>.from(json['languages']),
      isVerified: json['isVerified'],
      rating: json['rating'],
      biography: json['biography'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final City city;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.city,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      city: City.fromJson(json['city']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class City {
  final int id;
  final String name;
  final String createdAt;
  final String updatedAt;

  City({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class Location {
  final int id;
  final String latitude;
  final String longitude;
  final String label;
  final String createdAt;
  final String updatedAt;

  Location({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      label: json['label'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
