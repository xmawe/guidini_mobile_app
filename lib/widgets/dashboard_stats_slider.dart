import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/colors.dart';
import 'package:guidini/services/auth_service.dart';
import 'package:guidini/config/app_config.dart';

class DashboardStatsSlider extends StatefulWidget {
  const DashboardStatsSlider({Key? key}) : super(key: key);

  @override
  State<DashboardStatsSlider> createState() => _DashboardStatsSliderState();
}

class _DashboardStatsSliderState extends State<DashboardStatsSlider> {
  BookingStats? stats;
  bool isLoading = true;
  String? errorMessage;
  PageController pageController = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchBookingStats();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> fetchBookingStats() async {
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
        Uri.parse('http://192.168.200.8:8000/api/guide/bookings/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            stats = BookingStats.fromJson(responseData['data']);
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load booking stats');
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

  List<StatsCard> _buildStatsCards() {
    if (stats == null) return [];

    return [
      // Main Balance Card (Total Revenue)
      StatsCard(
        title: 'TOTAL REVENUE',
        value: '\$${stats!.totalRevenue}',
        subtitle: 'From ${stats!.totalBookings} bookings',
        icon: Icons.account_balance_wallet,
        color: AppColors.primary800,
        isMainCard: true,
      ),

      // Bookings Overview Card
      StatsCard(
        title: 'BOOKINGS OVERVIEW',
        value: '${stats!.totalBookings}',
        subtitle: 'Total bookings',
        icon: Icons.bookmark_outlined,
        color: AppColors.primary800,
        progressValue:
            stats!.confirmedBookings / stats!.totalBookings.toDouble(),
        progressLabel: '${stats!.confirmedBookings} confirmed',
      ),

      // This Month Activity Card
      StatsCard(
        title: 'THIS MONTH',
        value: '${stats!.thisMonthBookings}',
        subtitle: 'New bookings',
        icon: Icons.trending_up,
        color: Colors.green[600]!,
        badge: '${stats!.upcomingTours} upcoming',
      ),

      // Pending Bookings Card
      StatsCard(
        title: 'PENDING BOOKINGS',
        value: '${stats!.pendingBookings}',
        subtitle: 'Awaiting confirmation',
        icon: Icons.hourglass_empty,
        color: Colors.orange[600]!,
        showAlert: stats!.pendingBookings > 0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        height: 200,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 32),
              const SizedBox(height: 8),
              Text(
                'Failed to load stats',
                style: TextStyle(color: Colors.red[700], fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: fetchBookingStats,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final cards = _buildStatsCards();

    return Column(
      children: [
        SizedBox(
          height: 175,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: cards[index],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            cards.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: currentPage == index
                    ? AppColors.primary800
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isMainCard;
  final double? progressValue;
  final String? progressLabel;
  final String? badge;
  final bool showAlert;

  const StatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isMainCard = false,
    this.progressValue,
    this.progressLabel,
    this.badge,
    this.showAlert = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isMainCard
              ? [
                  AppColors.primary800,
                  AppColors.primary900,
                ]
              : [
                  Colors.white,
                  Colors.grey[50]!,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: (isMainCard ? Colors.white : color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isMainCard ? Colors.white70 : Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (showAlert)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Main Value
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isMainCard ? Colors.white : color)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: isMainCard ? Colors.white : color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isMainCard ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: isMainCard
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Progress Bar or Badge
                if (progressValue != null) ...[
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (progressLabel != null)
                        Text(
                          progressLabel!,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isMainCard ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: (isMainCard ? Colors.white : color)
                            .withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isMainCard ? Colors.white : color,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ] else if (badge != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          (isMainCard ? Colors.white : color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isMainCard ? Colors.white : color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data Model
class BookingStats {
  final int totalBookings;
  final int pendingBookings;
  final int confirmedBookings;
  final int completedBookings;
  final int cancelledBookings;
  final String totalRevenue;
  final int thisMonthBookings;
  final int upcomingTours;

  BookingStats({
    required this.totalBookings,
    required this.pendingBookings,
    required this.confirmedBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.totalRevenue,
    required this.thisMonthBookings,
    required this.upcomingTours,
  });

  factory BookingStats.fromJson(Map<String, dynamic> json) {
    return BookingStats(
      totalBookings: json['total_bookings'],
      pendingBookings: json['pending_bookings'],
      confirmedBookings: json['confirmed_bookings'],
      completedBookings: json['completed_bookings'],
      cancelledBookings: json['cancelled_bookings'],
      totalRevenue: json['total_revenue'],
      thisMonthBookings: json['this_month_bookings'],
      upcomingTours: json['upcoming_tours'],
    );
  }
}
