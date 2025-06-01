import 'package:flutter/material.dart';
import 'package:guidini/screens/guide/create_tour_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/colors.dart';
import 'package:guidini/services/auth_service.dart';

class MyToursScreen extends StatefulWidget {
  const MyToursScreen({Key? key}) : super(key: key);

  @override
  State<MyToursScreen> createState() => _MyToursScreenState();
}

class _MyToursScreenState extends State<MyToursScreen> {
  List<Tour> tours = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTours();
  }

  Future<void> fetchTours() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/guide/tours'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> toursData = responseData['data'];
          setState(() {
            tours =
                toursData.map((tourJson) => Tour.fromJson(tourJson)).toList();
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load tours');
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

  Future<void> _refreshTours() async {
    await fetchTours();
  }

  void _navigateToCreateTour(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTourScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _refreshTours,
        backgroundColor: Colors.grey[50],
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToCreateTour(context);
        },
        child: const Icon(
          Icons.add,
          color: AppColors.gray050,
        ),
        backgroundColor: AppColors.primary800,
        tooltip: 'Add Tour',
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
              'Error loading tours',
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
              onPressed: _refreshTours,
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

    if (tours.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tour_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tours found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first tour to get started',
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
      itemCount: tours.length,
      itemBuilder: (context, index) {
        return TourCard(tour: tours[index]);
      },
    );
  }
}

class TourCard extends StatelessWidget {
  final Tour tour;

  const TourCard({Key? key, required this.tour}) : super(key: key);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tour Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[200],
              child: tour.tourImages.isNotEmpty
                  ? Image.network(
                      tour.tourImages.first.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    )
                  : Icon(
                      Icons.tour,
                      size: 50,
                      color: Colors.grey[400],
                    ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating and Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.orange[600],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '4.5', // You can calculate this from reviews if available
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title
                    Expanded(
                      child: Text(
                        tour.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tour.location.label}, ${tour.city.name}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tour Features
                Row(
                  children: [
                    // Duration
                    _buildFeature(
                      Icons.access_time,
                      '${tour.duration} Hours',
                    ),
                    const SizedBox(width: 16),
                    // Food Included
                    if (tour.isFoodIncluded)
                      _buildFeature(
                        Icons.restaurant_outlined,
                        'Food Included',
                      ),
                    const SizedBox(width: 16),
                    // Activities count
                    _buildFeature(
                      Icons.local_activity_outlined,
                      '${tour.activities.length} Activities',
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Transport included
                if (tour.isTransportIncluded)
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Transport Included',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // Price and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Starts from',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          '\$${tour.price}/person',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: tour.availabilityStatus == 'available'
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: tour.availabilityStatus == 'available'
                              ? Colors.green[200]!
                              : Colors.orange[200]!,
                        ),
                      ),
                      child: Text(
                        tour.availabilityStatus.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: tour.availabilityStatus == 'available'
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
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
}

// Data Models
class Tour {
  final int id;
  final String title;
  final String description;
  final String price;
  final int duration;
  final int maxGroupSize;
  final String availabilityStatus;
  final bool isTransportIncluded;
  final bool isFoodIncluded;
  final Location location;
  final City city;
  final List<TourImage> tourImages;
  final List<Activity> activities;
  final List<TourDate> tourDates;

  Tour({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.maxGroupSize,
    required this.availabilityStatus,
    required this.isTransportIncluded,
    required this.isFoodIncluded,
    required this.location,
    required this.city,
    required this.tourImages,
    required this.activities,
    required this.tourDates,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      // bookingCount: json['bookingCount'],
      duration: json['duration'],
      maxGroupSize: json['maxGroupSize'],
      availabilityStatus: json['availabilityStatus'],
      isTransportIncluded: json['isTransportIncluded'] == 1,
      isFoodIncluded: json['isFoodIncluded'] == 1,
      location: Location.fromJson(json['location']),
      city: City.fromJson(json['city']),
      tourImages: (json['tourImages'] as List)
          .map((img) => TourImage.fromJson(img))
          .toList(),
      activities: (json['activities'] as List)
          .map((activity) => Activity.fromJson(activity))
          .toList(),
      tourDates: (json['tourDates'] as List)
          .map((date) => TourDate.fromJson(date))
          .toList(),
    );
  }
}

class Location {
  final int id;
  final String longitude;
  final String latitude;
  final String label;

  Location({
    required this.id,
    required this.longitude,
    required this.latitude,
    required this.label,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      label: json['label'],
    );
  }
}

class City {
  final int id;
  final String name;

  City({
    required this.id,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
    );
  }
}

class TourImage {
  final int id;
  final int tourId;
  final String imageUrl;

  TourImage({
    required this.id,
    required this.tourId,
    required this.imageUrl,
  });

  factory TourImage.fromJson(Map<String, dynamic> json) {
    return TourImage(
      id: json['id'],
      tourId: json['tourId'],
      imageUrl: json['imageUrl'],
    );
  }
}

class Activity {
  final int id;
  final String title;
  final String description;
  final int duration;
  final String price;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.price,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      price: json['price'],
    );
  }
}

class TourDate {
  final int id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  TourDate({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory TourDate.fromJson(Map<String, dynamic> json) {
    return TourDate(
      id: json['id'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}
