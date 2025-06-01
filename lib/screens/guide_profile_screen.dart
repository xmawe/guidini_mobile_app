import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/guide.dart';
import '../models/tour.dart';
import '../services/tour_service.dart';
import '../constants/colors.dart';
import '../widgets/tour/tour_card.dart';

class GuideProfileScreen extends StatefulWidget {
  final int guideId;

  const GuideProfileScreen({
    Key? key,
    required this.guideId,
  }) : super(key: key);

  @override
  State<GuideProfileScreen> createState() => _GuideProfileScreenState();
}

class _GuideProfileScreenState extends State<GuideProfileScreen> {
  late Future<Guide> _guideFuture;
  final TourService _tourService = TourService();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _guideFuture = _loadGuideData();
  }

  Future<Guide> _loadGuideData() async {
    try {
      final guide = await _tourService.getGuideById(widget.guideId);
      
      // Load additional user data (creation date, city info, online status)
      await guide.initUserData();
      
      setState(() {
        _isLoading = false;
      });
      return guide;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // For development/testing, return a mock guide
      return Guide.mockGuide();
    }
  }

  Widget _buildHeader(BuildContext context, Guide guide) {
    return Container(
      color: AppColors.gray100, // Light gray background
      child: Column(
        children: [
          // Top padding for status bar
          SizedBox(height: MediaQuery.of(context).padding.top + 10),
          
          // Back button and chat button row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                // Back button (smaller circle and icon)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.gray900, size: 20),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  ),
                ),

                // Chat button (smaller circle and icon)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEB), // light pink
                  shape: BoxShape.circle,
                  ),
                  child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/chat_bubble.svg',
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {
                    _initiateChat(guide);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Profile section with white background
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Profile picture
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.gray300,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gray900.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildProfileImage(guide.profilePicture),
                  ),
                ),
                
                // Name and verification badge
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            guide.fullName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'InstrumentSans',
                              color: AppColors.gray900,
                            ),
                          ),
                          if (guide.isVerified) const SizedBox(width: 8),
                          if (guide.isVerified)
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary700,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            color: AppColors.primary800,
                            size: 18,
                          ),
                          Text(
                            "${guide.rating}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray900,
                            ),
                          ),
                          Text(
                            " (${guide.reviewsCount} reviews)",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray600,
                              fontFamily: 'InstrumentSans',
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Guide subtitle
                      Text(
                        "Certified guide based in ${guide.cityName ?? "Marrakesh"}",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray600,
                          fontFamily: 'InstrumentSans',
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.primary700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            guide.cityName ?? "Marrakesh",
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'InstrumentSans',
                              color: AppColors.gray800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Online status indicator
                          if (guide.isOnline == true)
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Online',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontFamily: 'InstrumentSans',
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Languages
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Text(
                              "Languages : ",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'InstrumentSans',
                                color: AppColors.gray900,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                guide.languages.join(", "),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'InstrumentSans',
                                  color: AppColors.gray900,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Joined and Experience row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoPill(
                              icon: Icons.calendar_today,
                              iconColor: AppColors.primary700,
                              title: "Joined",
                              value: guide.userCreatedAt != null 
                                  ? guide.getJoinedTime()
                                  : "Unknown",
                            ),
                            const SizedBox(width: 16),
                            _buildInfoPill(
                              icon: Icons.work,
                              iconColor: AppColors.primary700,
                              title: "Experience",
                              value: guide.getExperienceTime(),
                            ),
                          ],
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
  
  Widget _buildProfileImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultProfileImage();
          },
        ),
      );
    } else {
      return _buildDefaultProfileImage();
    }
  }
  
  Widget _buildDefaultProfileImage() {
    return ClipOval(
      child: Container(
        width: 100,
        height: 100,
        color: AppColors.gray300,
        child: const Icon(
          Icons.person,
          size: 60,
          color: AppColors.gray600,
        ),
      ),
    );
  }
  
  Widget _buildInfoPill({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.gray050,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray600,
                      fontFamily: 'InstrumentSans',
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'InstrumentSans',
                      color: AppColors.gray900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getYearsAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    final years = difference.inDays / 365;
    
    if (years < 1) {
      final months = difference.inDays / 30;
      if (months < 1) {
        return 'Just joined';
      }
      return '${months.floor()} ${months.floor() == 1 ? 'month' : 'months'} ago';
    }
    
    return '${years.floor()} ${years.floor() == 1 ? 'year' : 'years'} ago';
  }

  String _formatExperience(int years) {
    if (years < 1) {
      return 'New guide';
    }
    return '$years ${years == 1 ? 'year' : 'years'}';
  }

  Widget _buildBiographySection(Guide guide) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            guide.biography,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              fontFamily: 'InstrumentSans',
              color: AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToursList(List<Tour> tours, String guideName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Get guided by $guideName",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'InstrumentSans',
              color: AppColors.gray900,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: tours.length,
          itemBuilder: (context, index) {
            return TourCard(
              tour: tours[index],
              onTap: () {
                // Handle tour booking
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking tour: ${tours[index].title}')),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _initiateChat(Guide guide) async {
    try {
      final result = await _tourService.contactGuide(guide.id, "Hello, I'm interested in your tours.");
      
      if (result.containsKey('chat_room_id')) {
        int chatRoomId = result['chat_room_id'];
        
        // Navigate to chat screen with this guide
        Navigator.pushNamed(
          context,
          '/chat',
          arguments: {
            'chatRoomId': chatRoomId,
            'guideName': guide.fullName,
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start conversation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Guide>(
        future: _guideFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary700));
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary700,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _guideFuture = _loadGuideData();
                      });
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          
          final guide = snapshot.data ?? Guide.mockGuide();
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, guide),
                _buildBiographySection(guide),
                const SizedBox(height: 16),
                _buildToursList(guide.tours ?? [], guide.firstName),
              ],
            ),
          );
        },
      ),
    );
  }
}