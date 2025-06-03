import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/colors.dart';
import 'package:guidini/services/auth_service.dart';
import 'package:guidini/config/app_config.dart';

class GuideBookingsScreen extends StatefulWidget {
  const GuideBookingsScreen({Key? key}) : super(key: key);

  @override
  State<GuideBookingsScreen> createState() => _GuideBookingsScreenState();
}

class _GuideBookingsScreenState extends State<GuideBookingsScreen> {
  List<Booking> bookings = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedFilter =
      'all'; // all, pending, confirmed, cancelled, completed

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      String url = '${AppConfig.apiHost}/api/guide/bookings';
      if (selectedFilter != 'all') {
        url += '?status=$selectedFilter';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> bookingsData = responseData['data'];
          setState(() {
            bookings = bookingsData
                .map((bookingJson) => Booking.fromJson(bookingJson))
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load bookings');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshBookings() async {
    await fetchBookings();
  }

  Future<void> _handleBookingAction(int bookingId, String action) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = action == 'accept'
          ? '${AppConfig.apiHost}/api/guide/bookings/$bookingId/accept'
          : '${AppConfig.apiHost}/api/guide/bookings/$bookingId/decline';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              backgroundColor: Colors.green,
            ),
          );
          await _refreshBookings();
        } else {
          throw Exception(responseData['message'] ?? 'Action failed');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text(
      //     'My Bookings',
      //     style: TextStyle(
      //       fontWeight: FontWeight.w600,
      //       color: Colors.black,
      //     ),
      //   ),
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   iconTheme: const IconThemeData(color: Colors.black),
      // ),
      body: Column(
        children: [
          const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 16.0, top: 10, bottom: 10), // adjust 16.0 as needed
                child: Text(
                  "My Bookings",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
          _buildFilterTabs(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshBookings,
              backgroundColor: Colors.grey[50],
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'All'),
            const SizedBox(width: 8),
            _buildFilterChip('pending', 'Pending'),
            const SizedBox(width: 8),
            _buildFilterChip('confirmed', 'Confirmed'),
            const SizedBox(width: 8),
            _buildFilterChip('completed', 'Completed'),
            const SizedBox(width: 8),
            _buildFilterChip('cancelled', 'Cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
        fetchBookings();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary800 : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary800 : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading bookings',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary800,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookings for your tours will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return BookingCard(
          booking: bookings[index],
          onAccept: () => _handleBookingAction(bookings[index].id, 'accept'),
          onDecline: () => _handleBookingAction(bookings[index].id, 'decline'),
        );
      },
    );
  }
}

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const BookingCard({
    Key? key,
    required this.booking,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Reference and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.bookingReference,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(booking.status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(booking.status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tour Title
            Text(
              booking.tour.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            // Location and Date
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${booking.tour.location.label}, ${booking.tour.city.name}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(booking.bookedDate),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Booking Details
            Row(
              children: [
                _buildDetailChip(
                    Icons.group_outlined, '${booking.groupSize} People'),
                const SizedBox(width: 12),
                _buildDetailChip(Icons.attach_money, '\$${booking.totalPrice}'),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons (only for pending bookings)
            if (booking.status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gray300,
                        side: const BorderSide(color: AppColors.gray100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

// Data Models
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
  final double rating;
  final Guide guide;
  final Location location;
  final City city;

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
    required this.city,
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
      rating: (json['rating'] ?? 0).toDouble(),
      guide: Guide.fromJson(json['guide']),
      location: Location.fromJson(json['location']),
      city: City.fromJson(json['city']),
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

  Guide({
    required this.id,
    required this.userId,
    required this.languages,
    required this.isVerified,
    required this.rating,
    required this.biography,
    required this.createdAt,
    required this.updatedAt,
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
