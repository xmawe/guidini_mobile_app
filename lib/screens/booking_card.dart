import 'package:flutter/material.dart';
import 'booking_item.dart';
import 'booking_details_screen.dart';
// Add this import for your API service
import '../services/api_service.dart';

class BookingCard extends StatelessWidget {
  final BookingItem booking;
  final bool isExpanded;
  final VoidCallback onTapExpand;

  const BookingCard({
    required this.booking,
    required this.isExpanded,
    required this.onTapExpand,
    Key? key,
  }) : super(key: key);

  void _showBookingDetails(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF800000)),
        ),
      ),
    );

    try {
      // Fetch activities for this booking's tour
      List<Map<String, dynamic>> activities = [];

      // If booking has a tour_id, use it to fetch activities
      if (booking.tourId != null) {
        activities = await ApiService.getTourActivities(booking.tourId!);
      } else {
        // Fallback: get all activities and filter by tour name or other criteria
        final allActivities = await ApiService.getAllActivities();
        // You might want to filter based on location or tour name
        activities = allActivities.where((activity) {
          // Example filter - adjust based on your data structure
          return activity['tour']?['name']
                  ?.toLowerCase()
                  .contains(booking.title.toLowerCase()) ??
              false;
        }).toList();
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Show booking details with activities
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => BookingDetailsBottomSheet(
          booking: booking,
          activities: activities,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load booking details: $e'),
          backgroundColor: Colors.red,
        ),
      );

      // Still show the bottom sheet but with empty activities
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => BookingDetailsBottomSheet(
          booking: booking,
          activities: [],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 12, 0, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Move date to the left
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        booking.date,
                        style: TextStyle(
                          color: Color(0xFF737373), // Gray-500
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Inter',
                          height: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      booking.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF404040), // Gray-700
                        fontFamily: 'Inter',
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      booking.location,
                      style: TextStyle(
                        color: Color(0xFF808080), // Gray-500
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "Guided by" text on top of the image
                            Text(
                              'Guided by',
                              style: TextStyle(
                                color: Color(0xFF808080), // Gray-500
                                fontSize: 6,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Inter',
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: 4),
                            // Updated guide image with specifications
                            Stack(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFD9D9D9), // Gray-100
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: Center(
                                    child: Text(
                                      booking.guide
                                          .split(' ')
                                          .map((e) => e.isNotEmpty ? e[0] : '')
                                          .join('')
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                // Checked icon - positioned as specified
                                Positioned(
                                  bottom: -1,
                                  right: -1,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF800000), // Primary-800
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.white, width: 1),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.check,
                                        size: 5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Guide name
                                  Flexible(
                                    child: Text(
                                      booking.guide,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Color(0xFF4D0000), // Primary-900
                                        fontFamily: 'Inter',
                                        height: 1.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  // Rating moved to the left close to name
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icons/star_filled.png',
                                        width: 10,
                                        height: 10,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        '${booking.rating}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF404040),
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text(
                                booking.location,
                                style: TextStyle(
                                  color: Color(0xFF800000), // Primary-800
                                  fontSize: 8,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Inter',
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Price on the right
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${booking.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1C1C), // Gray-950
                                fontFamily: 'Inter',
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () => _showBookingDetails(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF800000),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/eye_icon.png',
                                width: 16,
                                height: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'View details',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () {
                            // Add contact guide functionality here
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            // SnackBar(
                            //  content: Text('Contacting ${booking.guide}...'),
                            //   backgroundColor: Color(0xFF800000),
                            // ),
                            // );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color(0xFFF5F5F5),
                            foregroundColor: Color(0xFF4D0000),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            side: BorderSide(color: Colors.transparent),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/chat_icon.png',
                                width: 16,
                                height: 16,
                                color: Color(0xFF4D0000),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Contact guide',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
              InkWell(
                onTap: onTapExpand,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  child: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Status Badge
        Positioned(
          top: 0,
          right: 12,
          child: _buildStatusTag(),
        ),
      ],
    );
  }

  Widget _buildStatusTag() {
    Color backgroundColor;
    Color textColor;
    IconData iconData;
    String label;

    if (booking.isWaitingConfirmation) {
      backgroundColor = Color(0xFFE3F2FD); // Light blue
      textColor = Color(0xFF1976D2); // Blue
      iconData = Icons.access_time;
      label = 'Waiting for guide\'s confirmation';
    } else {
      backgroundColor = Color(0xFFE8F5E8); // Light green
      textColor = Color(0xFF2E7D32); // Green
      iconData = Icons.check;
      label = 'Confirmed';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 12,
            color: textColor,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
