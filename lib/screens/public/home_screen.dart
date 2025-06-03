import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guidini/constants/colors.dart' as app_color_utils;
import 'package:guidini/services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/tour.dart';
import '../../models/city.dart';
import 'package:guidini/config/app_config.dart';
import 'package:guidini/widgets/tour_card_widget.dart'; // Add this import

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
  String currentLocation = 'Select Location';
  List<City> cities = [];
  bool _hasShownLocationDialog = false;

  @override
  void initState() {
    super.initState();
    if (widget.userLocation != null && widget.userLocation!.isNotEmpty) {
      currentLocation = widget.userLocation!;
    }
    fetchCities();
    fetchTours();

    // Show location permission dialog after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownLocationDialog) {
        _showLocationPermissionDialog();
        _hasShownLocationDialog = true;
      }
    });
  }

  Future<void> _showLocationPermissionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: app_color_utils.AppColors.primary100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 40,
                    color: app_color_utils.AppColors.primaryRed,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Enable Location Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InstrumentSans',
                    color: app_color_utils.AppColors.gray950,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Allow us to access your location to show nearby tours and personalized recommendations.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'InstrumentSans',
                    color: app_color_utils.AppColors.grayText,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: app_color_utils.AppColors.gray300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Not Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'InstrumentSans',
                            color: app_color_utils.AppColors.gray700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _requestLocationPermission();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: app_color_utils.AppColors.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Allow',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'InstrumentSans',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedDialog();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update user location on backend
      await _updateUserLocation(position.latitude, position.longitude);
    } catch (e) {
      // print('Error getting location: $e');
    }
  }

  Future<void> _updateUserLocation(double latitude, double longitude) async {
    final token = await AuthService.getToken();
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiHost}/api/tours/update-location'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          currentLocation = data['location'];
        });
        fetchTours(); // Refresh tours with new location
      }
    } catch (e) {
      // print('Error updating location: $e');
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content:
            const Text('Please enable location services to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
            'Please grant location permission in your device settings to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> fetchTours() async {
    setState(() => isLoading = true);
    try {
      String locationParam =
          currentLocation == 'Select Location' ? '' : currentLocation;
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${AppConfig.apiHost}/api/tours?location=$locationParam'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // print('Status: ${response.statusCode}');
      // print('Body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        List<Tour> fetchedTours =
            data.map((json) => Tour.fromJson(json)).toList();

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
      // print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCities() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.apiHost}/api/cities'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          cities = data.map((json) => City.fromJson(json)).toList();
        });
      } else {
        // print('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error fetching cities: $e');
    }
  }

  String getUserInitials() {
    String firstName = widget.userFirstName ?? 'User';
    if (firstName.length >= 2) {
      return firstName.substring(0, 2).toUpperCase();
    } else if (firstName.length == 1) {
      return '${firstName.toUpperCase()}U';
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Container(
                    height: 100, // Upper half of the guide card section
                    color: app_color_utils.AppColors.primary800,
                  ),
                  isLoading
                      ? Center(
                          child: Lottie.asset(
                            'lib/assets/animations/loading_animation.json',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: topGuides.length,
                          itemBuilder: (context, index) {
                            if (index >= topGuides.length) {
                              return const SizedBox.shrink();
                            }
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
                  const Text(
                    'Tours Nearby',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: app_color_utils.AppColors.primaryRed,
                      fontFamily: 'InstrumentSans',
                    ),
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 12,
                              color: app_color_utils.AppColors.grayText,
                              fontFamily: 'InstrumentSans',
                            ),
                          ),
                          GestureDetector(
                            onTap: _showLocationPicker,
                            child: Row(
                              children: [
                                Text(
                                  currentLocation == 'Select Location'
                                      ? currentLocation
                                      : '$currentLocation, Morocco',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: currentLocation == 'Select Location'
                                        ? app_color_utils.AppColors.grayText
                                        : Colors.black,
                                    fontFamily: 'InstrumentSans',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Container(
                          // padding: const  EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: app_color_utils.AppColors.gray050,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.my_location,
                                color: app_color_utils.AppColors.primaryRed),
                            onPressed: _showLocationPicker,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Tour List - REPLACED WITH TourCardWidget
            isLoading
                ? Center(
                    child: Lottie.asset(
                      'lib/assets/animations/loading_animation.json',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tours.length,
                    itemBuilder: (context, index) {
                      final tour = tours[index];
                      return TourCardWidget(tour: tour); // Using the new widget
                    },
                  ),
            const SizedBox(height: 80), // Padding for bottom navigation bar
          ],
        ),
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
          decoration: const BoxDecoration(
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
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Location',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InstrumentSans',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: cities.isEmpty
                          ? Center(
                              child: Lottie.asset(
                                'lib/assets/animations/loading_animation.json',
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? app_color_utils.AppColors.primary100
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? app_color_utils.AppColors.primaryRed
                : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: isSelected
                  ? app_color_utils.AppColors.primaryRed
                  : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              '$locationName, Morocco',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? app_color_utils.AppColors.primaryRed
                    : Colors.black,
                fontFamily: 'InstrumentSans',
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: app_color_utils.AppColors.primaryRed,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, String title, Tour guide) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              color: app_color_utils.AppColors.primary100,
              child: const Icon(
                Icons.image,
                size: 50,
                color: app_color_utils.AppColors.primary300,
              ),
            ),
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  // ignore: deprecated_member_use
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: app_color_utils.AppColors.primary900,
                    fontFamily: 'InstrumentSans',
                  ),
                ),
                Text(
                  'WITH ${guide.guideName.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: app_color_utils.AppColors.primary900,
                    fontFamily: 'InstrumentSans',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Meet ${guide.guideName} ',
                      style: const TextStyle(
                        fontSize: 12,
                        color: app_color_utils.AppColors.primary900,
                        fontFamily: 'InstrumentSans',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      '#$title',
                      style: const TextStyle(
                        fontSize: 16,
                        color: app_color_utils.AppColors.primary900,
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
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: app_color_utils.AppColors.primary950,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Image.asset(
                            'lib/assets/images/icons/ic_check.png',
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: app_color_utils.AppColors.primary900,
                                fontFamily: 'InstrumentSans',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Image.asset(
                              'lib/assets/images/icons/ic_star.png',
                              width: 12,
                              height: 12,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.star,
                                    size: 12, color: Colors.white);
                              },
                            ),
                            Text(
                              guide.guideRating.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: app_color_utils.AppColors.primary900,
                                fontFamily: 'InstrumentSans',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          guide.city,
                          style: const TextStyle(
                            fontSize: 14,
                            color: app_color_utils.AppColors.primaryRed,
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
