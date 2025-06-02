import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'booking_item.dart';

class BookingDetailsBottomSheet extends StatefulWidget {
  final BookingItem booking;
  final List<Map<String, dynamic>> activities;

  const BookingDetailsBottomSheet({
    required this.booking,
    required this.activities,
    Key? key,
  }) : super(key: key);

  @override
  State<BookingDetailsBottomSheet> createState() =>
      _BookingDetailsBottomSheetState();
}

class _BookingDetailsBottomSheetState extends State<BookingDetailsBottomSheet> {
  String? tourImageUrl;
  bool isLoadingImage = true;

  @override
  void initState() {
    super.initState();
    _loadTourImage();
  }

  // Load tour image from API
  Future<void> _loadTourImage() async {
    try {
      // Replace with your actual API endpoint
      final response = await http.get(
        Uri.parse(
            'https://your-api-url.com/api/tours/${widget.booking.tourId}/images'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'].isNotEmpty) {
          setState(() {
            tourImageUrl = data['data'][0]['full_image_url'];
            isLoadingImage = false;
          });
        } else {
          setState(() {
            isLoadingImage = false;
          });
        }
      } else {
        setState(() {
          isLoadingImage = false;
        });
      }
    } catch (e) {
      print('Error loading tour image: $e');
      setState(() {
        isLoadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blur background
        Container(
          color: Colors.black.withOpacity(0.3),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Header Section with Image and Info Side by Side
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tour Image with Rating (Left Side)
                                Container(
                                  width: 220,
                                  height: 130,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                    color: Colors.transparent,
                                  ),
                                  child: Stack(
                                    children: [
                                      // Dynamic Tour Image
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                        child: _buildTourImage(),
                                      ),

                                      // Rating badge
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFE5E5),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                'assets/icons/star_filled.png',
                                                width: 12,
                                                height: 12,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${widget.booking.rating}',
                                                style: const TextStyle(
                                                  color: Color(0xFF4D0000),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Right Side Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Tour Title and Location
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.booking.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF333333),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            widget.booking.location
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16),

                                      // Guide Info Section
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // "Guided by" text on top of the image
                                              const Text(
                                                'Guided by',
                                                style: TextStyle(
                                                  color: Color(
                                                      0xFF808080), // Gray-500
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Inter',
                                                  height: 1.0,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              // Guide Avatar
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFD9D9D9),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        widget.booking.guide
                                                            .split(' ')
                                                            .map((e) =>
                                                                e.isNotEmpty
                                                                    ? e[0]
                                                                    : '')
                                                            .join('')
                                                            .toUpperCase(),
                                                        style: const TextStyle(
                                                          color: Colors.black54,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: -1,
                                                    right: -1,
                                                    child: Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFF800000),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7),
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 1.5),
                                                      ),
                                                      child: Center(
                                                        child: Image.asset(
                                                          'assets/icons/checkmark_icon.png',
                                                          width: 6,
                                                          height: 6,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 10),

                                          // Guide Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Name + rating
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        widget.booking.guide,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF800000),
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Image.asset(
                                                      'assets/icons/star_filled.png',
                                                      width: 12,
                                                      height: 12,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '${widget.booking.rating}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFF404040),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 4),

                                                // Location
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      size: 12,
                                                      color: Color(0xFF800000),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Expanded(
                                                      child: Text(
                                                        widget.booking.location,
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF800000),
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Tour Details Badges - Dynamic based on database data
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _buildDynamicBadges(),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Dynamic Itinerary Section
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildDynamicTimeline(),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Summary section
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total price',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'People',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Duration',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${widget.booking.price}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '${widget.booking.groupSize}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '${_getTotalDuration()} hours',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Build tour image widget with loading state
  Widget _buildTourImage() {
    if (isLoadingImage) {
      return Container(
        width: 220,
        height: 130,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF800000)),
          ),
        ),
      );
    }

    if (tourImageUrl != null && tourImageUrl!.isNotEmpty) {
      return Image.network(
        tourImageUrl!,
        width: 220,
        height: 130,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 220,
            height: 130,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF800000)),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage();
        },
      );
    }

    return _buildFallbackImage();
  }

  // Fallback image when no image is available
  Widget _buildFallbackImage() {
    return Container(
      width: 220,
      height: 130,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No Image Available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Build dynamic badges based on database data
  List<Widget> _buildDynamicBadges() {
    List<Widget> badges = [];

    // Always show duration if available
    int duration = _getTotalDuration();
    if (duration > 0) {
      String durationText = duration == 1 ? '1 Hour' : '$duration Hours';
      badges.add(_buildBadge('assets/icons/clock_icon.png', durationText));
    }

    // Show food badge only if food is included
    if (widget.booking.isFoodIncluded) {
      badges.add(_buildBadge('assets/icons/tea_icon.png', 'Food Included'));
    }

    // Show activities count if there are activities
    if (widget.activities.isNotEmpty) {
      String activitiesText = widget.activities.length == 1
          ? '1 Activity'
          : '${widget.activities.length} Activities';
      badges.add(_buildBadge('assets/icons/activity_icon.png', activitiesText));
    }

    // Show transport badge only if transport is included
    if (widget.booking.isTransportIncluded) {
      badges.add(_buildBadge('assets/icons/transport_icon.png', 'Transport'));
    }

    // Show booking status with appropriate styling
    badges.add(_buildStatusBadge(widget.booking.status));

    return badges;
  }

  // Status badge with different styling based on status
  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    Color textColor;
    String statusText;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'confirmed':
        badgeColor = const Color(0xFFE8F5E8);
        textColor = Colors.green.shade700;
        statusText = 'Confirmed';
        icon = Icons.check_circle;
        break;
      case 'pending':
        badgeColor = const Color(0xFFFFF3CD);
        textColor = Colors.orange.shade700;
        statusText = 'Pending';
        icon = Icons.schedule;
        break;
      case 'cancelled':
        badgeColor = const Color(0xFFFFEBEE);
        textColor = Colors.red.shade700;
        statusText = 'Cancelled';
        icon = Icons.cancel;
        break;
      default:
        badgeColor = const Color(0xFFF2F2F2);
        textColor = Colors.grey.shade600;
        statusText = status.substring(0, 1).toUpperCase() + status.substring(1);
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Calculate total duration from database or activities
  int _getTotalDuration() {
    // First try to get duration from booking data
    if (widget.booking.duration > 0) {
      return widget.booking.duration;
    }

    // Fallback to calculating from activities
    if (widget.activities.isEmpty) return 3; // fallback
    return widget.activities
        .fold(0, (sum, activity) => sum + (activity['duration'] as int? ?? 0));
  }

  // Build dynamic timeline from activities
  List<Widget> _buildDynamicTimeline() {
    if (widget.activities.isEmpty) {
      return [
        Text(
          'No activities available',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ];
    }

    List<Widget> timelineItems = [];

    for (int i = 0; i < widget.activities.length; i++) {
      final activity = widget.activities[i];
      final isFirst = i == 0;
      final isLast = i == widget.activities.length - 1;

      timelineItems.add(
        _buildTimelineItem(
          activity['title'] ?? 'Activity ${i + 1}',
          widget.booking.location, // Use booking location
          activity['description'] ?? 'No description available',
          _getCategoryName(activity),
          _getCategoryIcon(activity),
          isFirst: isFirst,
          isLast: isLast,
        ),
      );
    }

    return timelineItems;
  }

  // Get category name from activity
  String _getCategoryName(Map<String, dynamic> activity) {
    final categoryId = activity['activity_category_id'] as int? ?? 0;

    // Map category IDs to names based on your data structure
    switch (categoryId) {
      case 1:
        return 'Exploring';
      case 2:
        return 'Cultural Heritage';
      case 3:
        return 'Nature & Adventure';
      case 4:
        return 'Food & Drinks';
      case 5:
        return 'Water Activities';
      case 7:
        return 'Sports & Adventure';
      default:
        return 'Activity';
    }
  }

  // Get appropriate icon for category
  String _getCategoryIcon(Map<String, dynamic> activity) {
    final categoryId = activity['activity_category_id'] as int? ?? 0;

    switch (categoryId) {
      case 1:
        return 'assets/icons/explore_icon.png';
      case 2:
        return 'assets/icons/workshop_icon.png';
      case 3:
        return 'assets/icons/activity_icon.png';
      case 4:
        return 'assets/icons/tea_icon.png';
      case 5:
        return 'assets/icons/explore_icon.png';
      case 7:
        return 'assets/icons/activity_icon.png';
      default:
        return 'assets/icons/eye_icon.png';
    }
  }

  Widget _buildBadge(String iconAsset, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconAsset,
            width: 12,
            height: 12,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String location,
    String description,
    String category,
    String iconAsset, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline column
            Column(
              children: [
                // Timeline icon with frame
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB3B3),
                      borderRadius: BorderRadius.circular(28),
                      border:
                          Border.all(color: const Color(0xFFFFE5E5), width: 4),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/eye_icon.png',
                        width: 16,
                        height: 16,
                        color: const Color(0xFF800000),
                      ),
                    ),
                  ),
                ),
                // Timeline line - auto stretch
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF8C8C8C),
                          decoration: TextDecoration.underline,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/icons/export_icon.png',
                        width: 14,
                        height: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          iconAsset,
                          width: 12,
                          height: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
