import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guidini/screens/public/guide_profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:guidini/constants/colors.dart';
import 'package:guidini/services/auth_service.dart';
import 'package:guidini/config/app_config.dart';
import 'package:guidini/screens/public/booking_screen.dart';
import 'package:guidini/models/tour.dart';

class TourDetailScreen extends StatefulWidget {
  final int tourId;

  const TourDetailScreen({
    super.key,
    required this.tourId,
  });

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  Tour? tour;
  bool isLoading = true;
  List<Map<String, dynamic>> reviews = [];
  List<Map<String, dynamic>> activities = [];

  @override
  void initState() {
    super.initState();
    fetchTourDetails();
  }

  Future<void> fetchTourDetails() async {
    setState(() => isLoading = true);

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.apiHost}/api/tours/${widget.tourId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final tourData = responseData['data'];

        setState(() {
          tour = Tour.fromJson(tourData);
          reviews = List<Map<String, dynamic>>.from(tourData['reviews'] ?? []);
          activities =
              List<Map<String, dynamic>>.from(tourData['activities'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _navigateToGuideProfile() {
    if (tour?.guideId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GuideProfileScreen(
            guideId: tour!.guideId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary100),
        ),
      );
    }

    if (tour == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text(
            'Tour not found',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.black),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: tour!.imageUrl != null
                  ? Image.network(
                      tour!.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.gray050,
                          child: const Icon(Icons.image,
                              size: 100, color: AppColors.gray100),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.gray050,
                      child: const Icon(Icons.image,
                          size: 100, color: AppColors.gray100),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating Badge
                    if (tour!.tourRating > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: AppColors.primary900),
                            const SizedBox(width: 4),
                            Text(
                              tour!.tourRating.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary900,
                                fontFamily: 'InstrumentSans',
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Title and Location
                    Text(
                      tour!.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InstrumentSans',
                        color: AppColors.gray950,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tour!.location,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.grayText,
                        fontFamily: 'InstrumentSans',
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Guide Info - Made clickable
                    const Text(
                      'Guided by',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grayText,
                        fontFamily: 'InstrumentSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _navigateToGuideProfile,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary950,
                                  ),
                                ),
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: const Icon(Icons.check,
                                        size: 12, color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tour!.guideName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary900,
                                      fontFamily: 'InstrumentSans',
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 16, color: Colors.orange),
                                      const SizedBox(width: 4),
                                      Text(
                                        tour!.guideRating.toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.primary900,
                                          fontFamily: 'InstrumentSans',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        tour!.city,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.primaryRed,
                                          fontFamily: 'InstrumentSans',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.gray400,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tour Info Chips
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(
                            Icons.access_time, '${tour!.duration} Hours'),
                        if (tour!.isFoodIncluded)
                          _buildInfoChip(
                              Icons.restaurant_menu, 'Food Included'),
                        _buildInfoChip(Icons.location_on_outlined,
                            '${tour!.activitiesCount} Activities'),
                        if (tour!.isTransportIncluded)
                          _buildInfoChip(Icons.directions_car_outlined,
                              'Transport Included'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Activities Timeline
                    if (activities.isNotEmpty) ...[
                      const Text(
                        'Activities',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'InstrumentSans',
                          color: AppColors.gray950,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...activities.asMap().entries.map((entry) {
                        final index = entry.key;
                        final activity = entry.value;
                        return _buildActivityItem(activity, index + 1);
                      }).toList(),
                      const SizedBox(height: 24),
                    ],

                    // Description
                    const Text(
                      'About this tour',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InstrumentSans',
                        color: AppColors.gray950,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tour!.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.grayText,
                        fontFamily: 'InstrumentSans',
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Reviews Section
                    const Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InstrumentSans',
                        color: AppColors.gray950,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (reviews.isEmpty)
                      _buildReviewPlaceholders()
                    else
                      ...reviews
                          .map((review) => _buildReviewItem(review))
                          .toList(),

                    const SizedBox(height: 100), // Space for bottom bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Price Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total price',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grayText,
                      fontFamily: 'InstrumentSans',
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '\$${tour!.price.toInt()}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'InstrumentSans',
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '/ person',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grayText,
                          fontFamily: 'InstrumentSans',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(tour: tour!),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary900,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'InstrumentSans',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray050,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.gray300),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.gray700,
              fontFamily: 'InstrumentSans',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, int stepNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary900,
                  fontFamily: 'InstrumentSans',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Activity content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] ?? 'Activity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InstrumentSans',
                    color: AppColors.gray950,
                  ),
                ),
                const SizedBox(height: 4),
                if (activity['location'] != null)
                  Text(
                    activity['location']['label'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary900,
                      fontFamily: 'InstrumentSans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  activity['description'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grayText,
                    fontFamily: 'InstrumentSans',
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gray050,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Duration: ${activity['duration']} min',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray700,
                      fontFamily: 'InstrumentSans',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPlaceholders() {
    return Column(
      children: [
        _buildPlaceholderReview(
          'Sarah Johnson',
          5,
          'Amazing experience! The guide was very knowledgeable and showed us hidden gems of the city. Highly recommend this tour to anyone visiting.',
          '2 days ago',
        ),
        const SizedBox(height: 16),
        _buildPlaceholderReview(
          'Mike Chen',
          4,
          'Great tour with lots of interesting stops. The food was delicious and the guide spoke excellent English. Worth every penny!',
          '1 week ago',
        ),
      ],
    );
  }

  Widget _buildPlaceholderReview(
      String name, int rating, String comment, String timeAgo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray050,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    name[0],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary900,
                      fontFamily: 'InstrumentSans',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'InstrumentSans',
                        color: AppColors.gray950,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                            rating,
                            (index) => const Icon(Icons.star,
                                size: 16, color: Colors.orange)),
                        ...List.generate(
                            5 - rating,
                            (index) => const Icon(Icons.star_border,
                                size: 16, color: AppColors.gray300)),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grayText,
                            fontFamily: 'InstrumentSans',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grayText,
              fontFamily: 'InstrumentSans',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final user = review['user'];
    final userName = '${user['firstName']} ${user['lastName']}';
    final rating = review['rating'] ?? 0;
    final comment = review['comment'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray050,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    userName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary900,
                      fontFamily: 'InstrumentSans',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'InstrumentSans',
                        color: AppColors.gray950,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                            rating,
                            (index) => const Icon(Icons.star,
                                size: 16, color: Colors.orange)),
                        ...List.generate(
                            -rating,
                            (index) => const Icon(Icons.star_border,
                                size: 16, color: AppColors.gray300)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grayText,
              fontFamily: 'InstrumentSans',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
