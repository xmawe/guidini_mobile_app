import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:guidini/constants/colors.dart';
import 'package:guidini/models/tour.dart';
import 'package:guidini/services/auth_service.dart';
import 'package:guidini/config/app_config.dart';
import 'package:guidini/widgets/tour_card_widget.dart';

class GuideProfileScreen extends StatefulWidget {
  final int guideId;

  const GuideProfileScreen({
    super.key,
    required this.guideId,
  });

  @override
  State<GuideProfileScreen> createState() => _GuideProfileScreenState();
}

class _GuideProfileScreenState extends State<GuideProfileScreen> {
  Map<String, dynamic>? guideData;
  List<Tour> tours = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGuideProfile();
  }

  Future<void> fetchGuideProfile() async {
    setState(() => isLoading = true);

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.apiHost}/api/guides/${widget.guideId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'];

        setState(() {
          guideData = data;
          tours = (data['tours'] as List)
              .map((tourJson) => Tour.fromJson(tourJson))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
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

    if (guideData == null) {
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
            'Guide not found',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    final user = guideData!['user'];
    final fullName = '${user['firstName']} ${user['lastName']}';
    final rating = double.tryParse(guideData!['rating'].toString()) ?? 0.0;
    final languages = List<String>.from(guideData!['languages'] ?? []);
    final biography = guideData!['biography'] ?? '';
    final isVerified = guideData!['isVerified'] ?? false;
    final cityName = user['city']['name'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.gray050,
      body: CustomScrollView(
        slivers: [
          // Header with profile image and basic info
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.gray200,
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
                  icon: const Icon(Icons.more_horiz, color: Colors.black),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.gray200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    // Profile Avatar
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary950,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'G',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'InstrumentSans',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Name and verification
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'InstrumentSans',
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Certified guide based in $cityName',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.gray600,
                        fontFamily: 'InstrumentSans',
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'InstrumentSans',
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${tours.length} reviews)', // Placeholder for actual review count
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray600,
                            fontFamily: 'InstrumentSans',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Joined 4 Years ago', // Placeholder - could calculate from createdAt
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.gray600,
                        fontFamily: 'InstrumentSans',
                      ),
                    ),
                  ],
                ),
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
                    // Languages
                    if (languages.isNotEmpty) ...[
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.gray700,
                            fontFamily: 'InstrumentSans',
                          ),
                          children: [
                            const TextSpan(
                              text: 'Languages : ',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: languages.join(', '),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Biography
                    if (biography.isNotEmpty) ...[
                      Text(
                        biography,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.gray700,
                          fontFamily: 'InstrumentSans',
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Tours Section
                    Text(
                      'Get guided by ${user['firstName']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InstrumentSans',
                        color: AppColors.gray950,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tours List
                    if (tours.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'No tours available',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.grayText,
                              fontFamily: 'InstrumentSans',
                            ),
                          ),
                        ),
                      )
                    else
                      ...tours
                          .map((tour) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: TourCardWidget(tour: tour),
                              ))
                          .toList(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
