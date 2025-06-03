import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:guidini/constants/colors.dart';
import 'package:guidini/models/tour.dart';
import 'package:guidini/services/auth_service.dart';
import 'package:guidini/models/city.dart';
import 'package:guidini/models/activity_category.dart';
import 'package:guidini/config/app_config.dart';

// Import the separate widgets
import 'package:guidini/widgets/search_filters_widget.dart';
import 'package:guidini/widgets/tour_card_widget.dart';
import 'package:guidini/widgets/selection_modal_widget.dart';

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

  // Filter fields
  String keyword = '';
  String? cityId;
  String? categoryId;
  String? minPrice;
  String? maxPrice;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> priceRanges = [
    {'label': 'Any', 'min': '', 'max': ''},
    {'label': 'Under \$50', 'min': '', 'max': '50'},
    {'label': '\$50 - \$100', 'min': '50', 'max': '100'},
    {'label': '\$100 - \$200', 'min': '100', 'max': '200'},
    {'label': 'Over \$200', 'min': '200', 'max': ''},
  ];

  Map<String, String>? selectedPriceRange;

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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchTours() async {
    setState(() => isLoading = true);

    // Build query parameters
    final params = <String, String>{};
    if (keyword.isNotEmpty) params['keyword'] = keyword;
    if (cityId != null && cityId!.isNotEmpty) params['city_id'] = cityId!;
    if (categoryId != null && categoryId!.isNotEmpty) {
      params['category_id'] = categoryId!;
    }
    if (minPrice != null && minPrice!.isNotEmpty) {
      params['min_price'] = minPrice!;
    }
    if (maxPrice != null && maxPrice!.isNotEmpty) {
      params['max_price'] = maxPrice!;
    }

    final token = await AuthService.getToken();
    final uri = Uri.http(AppConfig.httpHost, '/api/tours', params);

    // DEBUG: Print the request details
    print('🔍 Fetching tours from: $uri');
    print('📊 Query params: $params');
    print('🔑 Token exists: ${token != null}');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // DEBUG: Print response details
      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('🔍 Decoded response data: $responseData');

        final List<dynamic> data = responseData['data'] ?? [];
        print('📋 Tours data array length: ${data.length}');

        if (data.isNotEmpty) {
          print('🎯 First tour sample: ${data[0]}');
        }

        try {
          final parsedTours = data.map((json) => Tour.fromJson(json)).toList();
          print('✅ Successfully parsed ${parsedTours.length} tours');

          setState(() {
            tours = parsedTours;
            isLoading = false;
          });
        } catch (parseError) {
          print('❌ Error parsing tours: $parseError');
          setState(() {
            tours = [];
            isLoading = false;
          });
        }
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        setState(() {
          tours = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('💥 Network Error fetching tours: $e');
      setState(() {
        tours = [];
        isLoading = false;
      });
    }
  }

  Future<void> fetchCities() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.apiHost}/api/cities'));

      print('🏙️ Cities response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['cities'] ?? [];
        setState(() {
          cities = data.map((json) => City.fromJson(json)).toList();
        });
        print('✅ Loaded ${cities.length} cities');
      } else {
        print('❌ Error fetching cities: ${response.statusCode}');
        setState(() {
          cities = [];
        });
      }
    } catch (e) {
      print('💥 Error fetching cities: $e');
      setState(() {
        cities = [];
      });
    }
  }

  Future<void> fetchActivityCategories() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.apiHost}/api/activity-categories'));

      print('🏃 Categories response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['activity_categories'] ?? [];
        setState(() {
          activityCategories =
              data.map((json) => ActivityCategory.fromJson(json)).toList();
        });
        print('✅ Loaded ${activityCategories.length} categories');
      } else {
        print('❌ Error fetching categories: ${response.statusCode}');
        setState(() {
          activityCategories = [];
        });
      }
    } catch (e) {
      print('💥 Error fetching categories: $e');
      setState(() {
        activityCategories = [];
      });
    }
  }

  void _onSearchPressed() {
    keyword = _searchController.text;
    print('🔍 Search pressed with keyword: "$keyword"');
    fetchTours();
  }

  void _onCitySelected(City? city) {
    setState(() {
      selectedCity = city;
      cityId = city?.id.toString();
    });
    print('🏙️ City selected: ${city?.name} (ID: $cityId)');
  }

  void _onCategorySelected(ActivityCategory? category) {
    setState(() {
      selectedActivityCategory = category;
      categoryId = category?.id.toString();
    });
    print('🏃 Category selected: ${category?.name} (ID: $categoryId)');
  }

  void _onPriceRangeSelected(Map<String, String>? range) {
    setState(() {
      selectedPriceRange = range;
      minPrice = range?['min'];
      maxPrice = range?['max'];
    });
    print(
        '💰 Price range selected: ${range?['label']} (min: $minPrice, max: $maxPrice)');
  }

  @override
  Widget build(BuildContext context) {
    // DEBUG: Print current state
    print(
        '🎨 Building SearchScreen - Tours count: ${tours.length}, Loading: $isLoading');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Search Filters Section at the top
            SearchFiltersWidget(
              searchController: _searchController,
              scrollController: _scrollController,
              cities: cities,
              selectedCity: selectedCity,
              activityCategories: activityCategories,
              selectedActivityCategory: selectedActivityCategory,
              priceRanges: priceRanges,
              selectedPriceRange: selectedPriceRange,
              onCityTap: () => _showCitySelectionModal(),
              onCategoryTap: () => _showCategorySelectionModal(),
              onPriceTap: () => _showPriceSelectionModal(),
              onSearchPressed: _onSearchPressed,
              onKeywordChanged: (value) => keyword = value,
            ),

            // Scrollable content below
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Divider
                  const SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Divider(
                          thickness: 1,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),

                  // DEBUG: Status indicator
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'DEBUG: Loading: $isLoading, Tours: ${tours.length}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Search Results Section
                  SliverToBoxAdapter(
                    child: isLoading
                        ? SizedBox(
                            height: 500,
                            child: Center(
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
                                    'Loading tours...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : tours.isEmpty
                            ? SizedBox(
                                height: 400,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'No tours found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          print('🔄 Manual refresh pressed');
                                          fetchTours();
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),

                  // Tours List
                  if (!isLoading && tours.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tour = tours[index];
                          print(
                              '🎫 Rendering tour ${index + 1}: ${tour.title}');
                          return TourCardWidget(tour: tour);
                        },
                        childCount: tours.length,
                      ),
                    ),

                  // Bottom padding for navigation bar
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCitySelectionModal() {
    SelectionModalWidget.showCityModal(
      context: context,
      cities: cities,
      selectedCity: selectedCity,
      onCitySelected: _onCitySelected,
    );
  }

  void _showCategorySelectionModal() {
    SelectionModalWidget.showCategoryModal(
      context: context,
      categories: activityCategories,
      selectedCategory: selectedActivityCategory,
      onCategorySelected: _onCategorySelected,
    );
  }

  void _showPriceSelectionModal() {
    SelectionModalWidget.showPriceModal(
      context: context,
      priceRanges: priceRanges,
      selectedPriceRange: selectedPriceRange,
      onPriceRangeSelected: _onPriceRangeSelected,
    );
  }
}
