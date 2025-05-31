import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import '../utils/colors.dart' as AppColorUtils;
import '../models/tour.dart';
import '../models/city.dart';
import '../models/activity_category.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Tour> tours = [];
  bool isLoading = false;
  List<City> cities = [];
  City? selectedCity;

  List<ActivityCategory> activityCategories = [];
  ActivityCategory? selectedActivityCategory;

  // Example filter fields
  String keyword = '';
  String? cityId;
  String? categoryId;
  String? minPrice;
  String? maxPrice;

  // Add TextEditingController for search field
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> priceRanges = [
    {'label': 'Any', 'min': '', 'max': ''},
    {'label': 'Under \$50', 'min': '', 'max': '50'},
    {'label': '\$50 - \$100', 'min': '50', 'max': '100'},
    {'label': '\$100 - \$200', 'min': '100', 'max': '200'},
    {'label': 'Over \$200', 'min': '200', 'max': ''},
  ];

  Map<String, String>? selectedPriceRange;

  Future<void> fetchTours() async {
    setState(() => isLoading = true);

    // Build query parameters
    final params = <String, String>{};
    if (keyword.isNotEmpty) params['keyword'] = keyword;
    if (cityId != null && cityId!.isNotEmpty) params['city_id'] = cityId!;
    if (categoryId != null && categoryId!.isNotEmpty) params['category_id'] = categoryId!;
    if (minPrice != null && minPrice!.isNotEmpty) params['min_price'] = minPrice!;
    if (maxPrice != null && maxPrice!.isNotEmpty) params['max_price'] = maxPrice!;

    final uri = Uri.http('127.0.0.1:8000', '/api/tours', params);

    try {
      print('Fetching tours from: $uri'); // Debug print
      final response = await http.get(uri);
      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        setState(() {
          tours = data.map((json) => Tour.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching tours: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchCities() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/cities'));
      print('Cities response status: ${response.statusCode}'); // Debug print
      print('Cities response body: ${response.body}'); // Debug print
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['cities'] ?? [];
        setState(() {
          cities = data.map((json) => City.fromJson(json)).toList();
        });
      } else {
        print('Error fetching cities: ${response.statusCode}');
        setState(() {
          cities = [];
        });
      }
    } catch (e) {
      print('Error fetching cities: $e');
      setState(() {
        cities = [];
      });
    }
  }

  Future<void> fetchActivityCategories() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/activity-categories'));
      print('Categories response status: ${response.statusCode}'); // Debug print
      print('Categories response body: ${response.body}'); // Debug print
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['activity_categories'] ?? [];
        setState(() {
          activityCategories = data.map((json) => ActivityCategory.fromJson(json)).toList();
        });
      } else {
        print('Error fetching categories: ${response.statusCode}');
        setState(() {
          activityCategories = [];
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        activityCategories = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTours();
    fetchCities();
    fetchActivityCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorUtils.AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
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
                            'MJ',
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
                              'Hello, Mohamed',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColorUtils.AppColors.gray900,
                                fontFamily: 'InstrumentSans',
                              ),
                            ),
                            Text(
                              'Ready for a tour ?',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColorUtils.AppColors.gray400,
                                fontFamily: 'InstrumentSans',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          color: AppColorUtils.AppColors.gray700,
                          size: 28,
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColorUtils.AppColors.primary400,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Search Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildSearchField(
                      context,
                      hint: 'EI Search activity, guide, city',
                      icon: 'assets/images/icons/ic_search2.png',
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showCitySelectionModal,
                      child: AbsorbPointer(
                        child: DropdownButtonFormField<City>(
                          value: selectedCity,
                          items: cities.map((city) {
                            return DropdownMenuItem<City>(
                              value: city,
                              child: Text(city.name),
                            );
                          }).toList(),
                          onChanged: (city) {
                            setState(() {
                              selectedCity = city;
                              cityId = city?.id.toString();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'City',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(
                                'assets/images/icons/ic_city.png',
                                width: 22,
                                height: 22,
                                color: AppColorUtils.AppColors.gray400,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.location_city, 
                                    size: 22, 
                                    color: AppColorUtils.AppColors.gray400);
                                },
                              ),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Fixed Row layout for Category and Price dropdowns
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: _showCategorySelectionModal,
                            child: AbsorbPointer(
                              child: DropdownButtonFormField<ActivityCategory>(
                                value: selectedActivityCategory,
                                items: activityCategories.map((category) {
                                  return DropdownMenuItem<ActivityCategory>(
                                    value: category,
                                    child: Text(category.name),
                                  );
                                }).toList(),
                                onChanged: (category) {
                                  setState(() {
                                    selectedActivityCategory = category;
                                    categoryId = category?.id.toString();
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Category',
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Image.asset(
                                      'assets/images/icons/ic_category.png',
                                      width: 22,
                                      height: 22,
                                      color: AppColorUtils.AppColors.gray400,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.category, 
                                          size: 22, 
                                          color: AppColorUtils.AppColors.gray400);
                                      },
                                    ),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: _showPriceSelectionModal,
                            child: AbsorbPointer(
                              child: DropdownButtonFormField<Map<String, String>>(
                                value: selectedPriceRange,
                                items: priceRanges.map((range) {
                                  return DropdownMenuItem<Map<String, String>>(
                                    value: range,
                                    child: Text(range['label']!),
                                  );
                                }).toList(),
                                onChanged: (range) {
                                  setState(() {
                                    selectedPriceRange = range;
                                    minPrice = range?['min'];
                                    maxPrice = range?['max'];
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Price',
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Image.asset(
                                      'assets/images/icons/ic_price.png',
                                      width: 22,
                                      height: 22,
                                      color: AppColorUtils.AppColors.gray400,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.attach_money, 
                                          size: 22, 
                                          color: AppColorUtils.AppColors.gray400);
                                      },
                                    ),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorUtils.AppColors.primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          keyword = _searchController.text;
                          fetchTours();
                        },
                        child: Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'InstrumentSans',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Divider(thickness: 1, color: AppColorUtils.AppColors.grayLight),
              // Search Results
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: isLoading
                    ? Center(
                        child: Lottie.asset(
                          'assets/animations/loading_animation.json',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      )
                    : tours.isEmpty
                        ? const Center(
                            child: Text(
                              'No tours found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
              ),
              const SizedBox(height: 80), // Padding for bottom navigation bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColorUtils.AppColors.white,
        selectedItemColor: AppColorUtils.AppColors.primaryRed,
        unselectedItemColor: AppColorUtils.AppColors.grayText,
        showUnselectedLabels: true,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'InstrumentSans',
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'InstrumentSans',
          fontSize: 12,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icons/ic_home.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.home, size: 24);
              },
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icons/ic_search.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.search, size: 24);
              },
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icons/ic_bookings.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.book_online, size: 24);
              },
            ),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icons/ic_conversations.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.chat, size: 24);
              },
            ),
            label: 'Conversations',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context,
      {required String hint, required String icon, IconData? trailing}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColorUtils.AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Image.asset(
            icon,
            width: 22, 
            height: 22, 
            color: AppColorUtils.AppColors.gray400,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.search, 
                size: 22, 
                color: AppColorUtils.AppColors.gray400);
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                keyword = value;
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColorUtils.AppColors.gray400,
                  fontFamily: 'InstrumentSans',
                  fontSize: 16,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                color: AppColorUtils.AppColors.gray900,
                fontFamily: 'InstrumentSans',
                fontSize: 16,
              ),
            ),
          ),
          if (trailing != null)
            Icon(trailing, color: AppColorUtils.AppColors.gray400),
          const SizedBox(width: 16),
        ],
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColorUtils.AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // TOP SECTION: Image + Details (No Price)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT: Larger Image with rating overlay
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Container(
                        width: 120,
                        height: 120,
                        color: AppColorUtils.AppColors.grayLight,
                        child: Icon(Icons.image,
                            size: 40, color: AppColorUtils.AppColors.gray400),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
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
                                return const Icon(Icons.star, size: 12);
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

                // RIGHT: Tour details (expanded to fill remaining space)
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
                              // Verification check icon
                              Positioned(
                                right: -1,
                                bottom: -1,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/icons/ic_check.png',
                                      width: 8,
                                      height: 8,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.check, size: 8);
                                      },
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
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.star, size: 12);
                            },
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

            // BOTTOM SECTION: Info chips + Price
            Row(
              children: [
                // LEFT: Info chips
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

                // RIGHT: Price section
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'InstrumentSans',
                          ),
                          overflow: TextOverflow.ellipsis,
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
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, 
                              size: 12, 
                              color: AppColorUtils.AppColors.gray700);
                          },
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.info, 
                size: 12, 
                color: AppColorUtils.AppColors.gray200);
            },
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

  void _showCitySelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Make background transparent to see rounded corners
      isScrollControlled: true, // Allow the modal to take up more space and be scrollable
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7, // Limit the height to 70% of screen
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), // Rounded top corners
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Handle color
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(
                  'Select City',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InstrumentSans',
                  ),
                ),
              ),
              // List of cities
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCity = city;
                          cityId = city.id.toString();
                        });
                        Navigator.pop(context); // Close the modal
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Margin between items
                        padding: const EdgeInsets.all(16), // Inner padding
                        decoration: BoxDecoration(
                          color: selectedCity == city ? AppColorUtils.AppColors.primary100 : Colors.grey[50], // Highlight selected
                          borderRadius: BorderRadius.circular(12), // Rounded corners for item
                          border: Border.all(
                            color: selectedCity == city ? AppColorUtils.AppColors.primaryRed : Colors.grey[200]!,
                            width: selectedCity == city ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on, // Location icon
                              color: selectedCity == city ? AppColorUtils.AppColors.primaryRed : Colors.grey[400],
                              size: 20,
                            ),
                            const SizedBox(width: 12), // Spacing between icon and text
                            Expanded(
                              child: Text(
                                '${city.name}, Morocco', // Display city name
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: selectedCity == city ? FontWeight.bold : FontWeight.normal,
                                  color: selectedCity == city ? AppColorUtils.AppColors.primaryRed : Colors.black,
                                  fontFamily: 'InstrumentSans',
                                ),
                                overflow: TextOverflow.ellipsis, // Handle long names
                              ),
                            ),
                            if (selectedCity == city)
                              Icon(
                                Icons.check_circle, // Checkmark for selected item
                                color: AppColorUtils.AppColors.primaryRed,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20), // Spacing at the bottom
            ],
          ),
        );
      },
    );
  }

  void _showCategorySelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Make background transparent to see rounded corners
      isScrollControlled: true, // Allow the modal to take up more space and be scrollable
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7, // Limit the height to 70% of screen
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), // Rounded top corners
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Handle color
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(
                  'Select Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InstrumentSans',
                  ),
                ),
              ),
              // List of categories
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: activityCategories.length,
                  itemBuilder: (context, index) {
                    final category = activityCategories[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedActivityCategory = category;
                          categoryId = category.id.toString();
                        });
                        Navigator.pop(context); // Close the modal
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Margin between items
                        padding: const EdgeInsets.all(16), // Inner padding
                        decoration: BoxDecoration(
                          color: selectedActivityCategory == category ? AppColorUtils.AppColors.primary100 : Colors.grey[50], // Highlight selected
                          borderRadius: BorderRadius.circular(12), // Rounded corners for item
                          border: Border.all(
                            color: selectedActivityCategory == category ? AppColorUtils.AppColors.primaryRed : Colors.grey[200]!,
                            width: selectedActivityCategory == category ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.category, // Category icon
                              color: selectedActivityCategory == category ? AppColorUtils.AppColors.primaryRed : Colors.grey[400],
                              size: 20,
                            ),
                            const SizedBox(width: 12), // Spacing between icon and text
                            Expanded(
                              child: Text(
                                category.name, // Display category name
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: selectedActivityCategory == category ? FontWeight.bold : FontWeight.normal,
                                  color: selectedActivityCategory == category ? AppColorUtils.AppColors.primaryRed : Colors.black,
                                  fontFamily: 'InstrumentSans',
                                ),
                                overflow: TextOverflow.ellipsis, // Handle long names
                              ),
                            ),
                            if (selectedActivityCategory == category)
                              Icon(
                                Icons.check_circle, // Checkmark for selected item
                                color: AppColorUtils.AppColors.primaryRed,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20), // Spacing at the bottom
            ],
          ),
        );
      },
    );
  }

  void _showPriceSelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Make background transparent to see rounded corners
      isScrollControlled: true, // Allow the modal to take up more space and be scrollable
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7, // Limit the height to 70% of screen
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), // Rounded top corners
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Handle color
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(
                  'Select Price Range',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InstrumentSans',
                  ),
                ),
              ),
              // List of price ranges
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: priceRanges.length,
                  itemBuilder: (context, index) {
                    final range = priceRanges[index];
                    bool isSelected = selectedPriceRange == range; // Determine if this range is selected
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPriceRange = range;
                          minPrice = range['min'];
                          maxPrice = range['max'];
                        });
                        Navigator.pop(context); // Close the modal
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Margin between items
                        padding: const EdgeInsets.all(16), // Inner padding
                        decoration: BoxDecoration(
                          color: isSelected ? AppColorUtils.AppColors.primary100 : Colors.grey[50], // Highlight selected
                          borderRadius: BorderRadius.circular(12), // Rounded corners for item
                          border: Border.all(
                            color: isSelected ? AppColorUtils.AppColors.primaryRed : Colors.grey[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_money, // Price icon
                              color: isSelected ? AppColorUtils.AppColors.primaryRed : Colors.grey[400],
                              size: 20,
                            ),
                            const SizedBox(width: 12), // Spacing between icon and text
                            Expanded(
                              child: Text(
                                range['label']!, // Display price range label
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppColorUtils.AppColors.primaryRed : Colors.black,
                                  fontFamily: 'InstrumentSans',
                                ),
                                overflow: TextOverflow.ellipsis, // Handle long names
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle, // Checkmark for selected item
                                color: AppColorUtils.AppColors.primaryRed,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20), // Spacing at the bottom
            ],
          ),
        );
      },
    );
  }
}