import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/colors.dart' as AppColorUtils;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tour.dart';
import '../models/city.dart';

class HomeScreen extends StatefulWidget {
  final String? userFirstName;
  final String? userLocation;

  const HomeScreen({
    super.key,
    this.userFirstName,
    this.userLocation,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Tour> tours = [];
  List<Tour> topGuides = [];
  bool isLoading = true;
  String currentLocation = 'Marrakesh';
  List<City> cities = [];

  @override
  void initState() {
    super.initState();
    if (widget.userLocation != null && widget.userLocation!.isNotEmpty) {
      currentLocation = widget.userLocation!;
    }
    fetchCities();
    fetchTours();
  }

  Future<void> fetchTours() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/tours?location=$currentLocation'));
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        List<Tour> fetchedTours = data.map((json) => Tour.fromJson(json)).toList();

        setState(() {
          tours = fetchedTours;
          topGuides = getTopGuides(fetchedTours);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCities() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/cities'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          cities = data.map((json) => City.fromJson(json)).toList();
        });
      } else {
        print('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  String getUserInitials() {
    String firstName = widget.userFirstName ?? 'User';
    if (firstName.length >= 2) {
      return firstName.substring(0, 2).toUpperCase();
    } else if (firstName.length == 1) {
      return firstName.toUpperCase() + 'U';
    }
    return 'MJ';
  }

  String getFirstName() {
    return widget.userFirstName ?? 'Guest';
  }

  List<Tour> getTopGuides(List<Tour> allTours) {
    Map<String, Tour> guideMap = {};

    for (Tour tour in allTours) {
      String guideKey = tour.guideName;
      if (!guideMap.containsKey(guideKey) ||
          tour.guideRating > guideMap[guideKey]!.guideRating) {
        guideMap[guideKey] = tour;
      }
    }

    List<Tour> sortedGuides = guideMap.values.toList();
    sortedGuides.sort((a, b) => b.guideRating.compareTo(a.guideRating));

    return sortedGuides.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with red background
            Container(
              color: AppColorUtils.AppColors.primary900,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColorUtils.AppColors.primary100,
                        child: Text(
                          getUserInitials(),
                          style: TextStyle(
                            color: AppColorUtils.AppColors.primaryRed,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'InstrumentSans',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${getFirstName()}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColorUtils.AppColors.white,
                              fontFamily: 'InstrumentSans',
                            ),
                          ),
                          Text(
                            'Ready for a tour?',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColorUtils.AppColors.white.withOpacity(0.8),
                              fontFamily: 'InstrumentSans',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/icons/ic_notification.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColorUtils.AppColors.primary600,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Guide Carousel with half red background
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Container(
                    height: 100, // Upper half of the guide card section
                    color: AppColorUtils.AppColors.primary900,
                  ),
                  isLoading
                      ? Center(
                          child: Lottie.asset(
                            'assets/animations/loading_animation.json',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: topGuides.length,
                          itemBuilder: (context, index) {
                            if (index >= topGuides.length) return SizedBox.shrink();
                            final guide = topGuides[index];
                            String title = '';
                            if (index == 0) {
                              title = 'Guide of the Year';
                            } else if (index == 1) {
                              title = 'Guide of the Month';
                            } else if (index == 2) {
                              title = 'Guide of the Week';
                            }
                            return _buildGuideCard(context, title, guide);
                          },
                        ),
                ],
              ),
            ),
            // Tours Nearby Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Tours Nearby',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColorUtils.AppColors.primaryRed,
                      fontFamily: 'InstrumentSans',
                    ),
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColorUtils.AppColors.grayText,
                              fontFamily: 'InstrumentSans',
                            ),
                          ),
                          GestureDetector(
                            onTap: _showLocationPicker,
                            child: Row(
                              children: [
                                Text(
                                  '$currentLocation, Morocco',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontFamily: 'InstrumentSans',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColorUtils.AppColors.primary100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/images/icons/ic_location.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Tour List
            isLoading
                ? Center(
                    child: Lottie.asset(
                      'assets/animations/loading_animation.json',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: tours.length,
                    itemBuilder: (context, index) {
                      final tour = tours[index];
                      return _buildTourCard(
                        title: tour.title,
                        location: tour.city,
                        guideName: tour.guideName,
                        rating: tour.guideRating.toString(),
                        price: tour.price.toString(),
                        duration: '${tour.duration} Hours',
                        foodIncluded: tour.isFoodIncluded,
                        activities: '${tour.activitiesCount} Activities',
                        transportIncluded: tour.isTransportIncluded,
                      );
                    },
                  ),
            const SizedBox(height: 80), // Padding for bottom navigation bar
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColorUtils.AppColors.white,
        selectedItemColor: AppColorUtils.AppColors.primaryRed,
        unselectedItemColor: AppColorUtils.AppColors.grayText,
        showUnselectedLabels: true,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: 'InstrumentSans',
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'InstrumentSans',
          fontSize: 12,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icons/ic_home.png',
              width: 24,
              height: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icons/ic_search.png',
              width: 24,
              height: 24,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icons/ic_bookings.png',
              width: 24,
              height: 24,
            ),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icons/ic_conversations.png',
              width: 24,
              height: 24,
            ),
            label: 'Conversations',
          ),
        ],
      ),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Allow modal to take full height if needed
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Location',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InstrumentSans',
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: cities.isEmpty
                          ? Center(
                              child: Lottie.asset(
                                'assets/animations/loading_animation.json',
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            )
                          : ListView.builder(
                              itemCount: cities.length,
                              itemBuilder: (context, index) {
                                return _buildLocationOption(cities[index].name);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationOption(String locationName) {
    bool isSelected = currentLocation == locationName;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentLocation = locationName;
        });
        Navigator.pop(context);
        fetchTours();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColorUtils.AppColors.primary100 : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColorUtils.AppColors.primaryRed : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: isSelected ? AppColorUtils.AppColors.primaryRed : Colors.grey[400],
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              '$locationName, Morocco',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColorUtils.AppColors.primaryRed : Colors.black,
                fontFamily: 'InstrumentSans',
              ),
            ),
            Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColorUtils.AppColors.primaryRed,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourCard({
    required String title,
    required String location,
    required String guideName,
    required String rating,
    required String price,
    required String duration,
    required bool foodIncluded,
    required String activities,
    required bool transportIncluded,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColorUtils.AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Container(
                        width: 120,
                        height: 120,
                        color: AppColorUtils.AppColors.grayLight,
                        child: Icon(Icons.image, size: 40, color: AppColorUtils.AppColors.gray400),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColorUtils.AppColors.primary100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/icons/ic_star.png',
                              width: 12,
                              height: 12,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.star, size: 12);
                              },
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColorUtils.AppColors.primary900,
                                fontFamily: 'InstrumentSans',
                              ),
                            ),
                          ],
                        ),
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
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'InstrumentSans',
                          color: AppColorUtils.AppColors.gray950,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColorUtils.AppColors.grayText,
                          fontFamily: 'InstrumentSans',
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Guided by',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColorUtils.AppColors.grayText,
                          fontFamily: 'InstrumentSans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColorUtils.AppColors.primary950,
                                ),
                              ),
                              Positioned(
                                right: -1,
                                bottom: -1,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/icons/ic_check.png',
                                      width: 8,
                                      height: 8,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            guideName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColorUtils.AppColors.primary900,
                              fontFamily: 'InstrumentSans',
                            ),
                          ),
                          const SizedBox(width: 4),
                          Image.asset(
                            'assets/images/icons/ic_star.png',
                            width: 12,
                            height: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColorUtils.AppColors.primary900,
                              fontFamily: 'InstrumentSans',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColorUtils.AppColors.primaryRed,
                          fontFamily: 'InstrumentSans',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip('assets/images/icons/ic_time.png', duration),
                      if (foodIncluded)
                        _buildInfoChip('assets/images/icons/ic_food.png', 'Food Included'),
                      _buildInfoChip('assets/images/icons/ic_activities.png', activities),
                      if (transportIncluded)
                        _buildInfoChip('assets/images/icons/ic_transport.png', 'Transport Included'),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Starts from',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColorUtils.AppColors.grayText,
                        fontFamily: 'InstrumentSans',
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$$price',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'InstrumentSans',
                          ),
                        ),
                        Text(
                          '/',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColorUtils.AppColors.grayText,
                            fontFamily: 'InstrumentSans',
                          ),
                        ),
                        const SizedBox(width: 2),
                        Image.asset(
                          'assets/images/icons/ic_person.png',
                          width: 12,
                          height: 12,
                          color: AppColorUtils.AppColors.gray700,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String iconPath, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColorUtils.AppColors.grayLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: 12,
            height: 12,
            color: AppColorUtils.AppColors.gray200,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: AppColorUtils.AppColors.gray700,
              fontFamily: 'InstrumentSans',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, String title, Tour guide) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: 200,
              color: AppColorUtils.AppColors.primary100,
              child: Icon(
                Icons.image,
                size: 50,
                color: AppColorUtils.AppColors.primary300,
              ),
            ),
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guide.title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColorUtils.AppColors.primary900,
                    fontFamily: 'InstrumentSans',
                  ),
                ),
                Text(
                  'WITH ${guide.guideName.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColorUtils.AppColors.primary900,
                    fontFamily: 'InstrumentSans',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Meet ${guide.guideName} ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColorUtils.AppColors.primary900,
                        fontFamily: 'InstrumentSans',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      '#$title',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColorUtils.AppColors.primary900,
                        fontFamily: 'DancingScript',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColorUtils.AppColors.primary950,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Image.asset(
                            'assets/images/icons/ic_check.png',
                            width: 18,
                            height: 18,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              guide.guideName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColorUtils.AppColors.primary900,
                                fontFamily: 'InstrumentSans',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Image.asset(
                              'assets/images/icons/ic_star.png',
                              width: 12,
                              height: 12,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.star, size: 12, color: Colors.white);
                              },
                            ),
                            Text(
                              guide.guideRating.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColorUtils.AppColors.primary900,
                                fontFamily: 'InstrumentSans',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          guide.city,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColorUtils.AppColors.primaryRed,
                            fontFamily: 'InstrumentSans',
                          ),
                        ),
                      ],
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
}