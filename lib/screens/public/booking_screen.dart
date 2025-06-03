import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:guidini/constants/colors.dart';
import 'package:guidini/models/tour.dart';
import 'package:guidini/services/auth_service.dart';
import 'package:guidini/config/app_config.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final Tour tour;

  const BookingScreen({
    super.key,
    required this.tour,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with TickerProviderStateMixin {
  bool isLoadingDates = false;
  bool isBooking = false;
  List<Map<String, dynamic>> availableDates = [];
  Map<String, dynamic>? selectedDate;
  int groupSize = 1;
  double totalPrice = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    fetchAvailableDates();
    _calculateTotalPrice();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateTotalPrice() {
    setState(() {
      totalPrice = widget.tour.price * groupSize;
    });
  }

  Future<void> fetchAvailableDates() async {
    setState(() => isLoadingDates = true);

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(
            '${AppConfig.apiHost}/api/tours/${widget.tour.id}/available-dates'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          availableDates = List<Map<String, dynamic>>.from(
              responseData['available_dates'] ?? []);
          isLoadingDates = false;
        });
      } else {
        setState(() => isLoadingDates = false);
        _showErrorSnackBar('Failed to load available dates');
      }
    } catch (e) {
      setState(() => isLoadingDates = false);
      _showErrorSnackBar('Network error occurred');
    }
  }

  Future<void> _processBooking() async {
    if (selectedDate == null) {
      _showErrorSnackBar('Please select a date');
      return;
    }

    setState(() => isBooking = true);

    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.apiHost}/api/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'tour_id': widget.tour.id,
          'tour_date_id': selectedDate!['tour_date_id'],
          'booked_date': selectedDate!['date'],
          'group_size': groupSize,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['success']) {
        // Show success dialog
        _showBookingSuccessDialog(responseData['booking']);
      } else {
        _showErrorSnackBar(responseData['message'] ?? 'Booking failed');
      }
    } catch (e) {
      _showErrorSnackBar('Network error occurred');
    } finally {
      setState(() => isBooking = false);
    }
  }

  void _showBookingSuccessDialog(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'InstrumentSans',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your booking reference: ${booking['booking_reference']}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary900,
                fontFamily: 'InstrumentSans',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You will receive a confirmation email shortly with all the details.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grayText,
                fontFamily: 'InstrumentSans',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to tour details
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: AppColors.primary900,
                fontWeight: FontWeight.w600,
                fontFamily: 'InstrumentSans',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Your Tour',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'InstrumentSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Tour Summary Card
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: widget.tour.imageUrl != null
                                ? Image.network(
                                    widget.tour.imageUrl!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: AppColors.gray050,
                                        child: const Icon(Icons.image,
                                            color: AppColors.gray300),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: AppColors.gray050,
                                    child: const Icon(Icons.image,
                                        color: AppColors.gray300),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.tour.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'InstrumentSans',
                                    color: AppColors.gray950,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.tour.location,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grayText,
                                    fontFamily: 'InstrumentSans',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 16, color: AppColors.gray400),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.tour.duration} hours',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.gray700,
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
                    ],
                  ),
                ),

                // Date Selection
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: AppColors.primary900, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Select Date',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'InstrumentSans',
                              color: AppColors.gray950,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (isLoadingDates)
                        const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary100),
                        )
                      else if (availableDates.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.gray050,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'No available dates found for this tour.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grayText,
                              fontFamily: 'InstrumentSans',
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: availableDates.length > 10
                                ? 10
                                : availableDates.length,
                            itemBuilder: (context, index) {
                              final date = availableDates[index];
                              final dateTime = DateTime.parse(date['date']);
                              final isSelected =
                                  selectedDate?['date'] == date['date'];

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedDate = date;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.all(16),
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary900
                                        : AppColors.gray050,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary900
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('EEE').format(dateTime),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.grayText,
                                          fontFamily: 'InstrumentSans',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('d').format(dateTime),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.gray950,
                                          fontFamily: 'InstrumentSans',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('MMM').format(dateTime),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.grayText,
                                          fontFamily: 'InstrumentSans',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      if (selectedDate != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary100.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 16, color: AppColors.primary900),
                              const SizedBox(width: 8),
                              Text(
                                '${selectedDate!['start_time']} - ${selectedDate!['end_time']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary900,
                                  fontFamily: 'InstrumentSans',
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${selectedDate!['remaining_capacity']} spots left',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'InstrumentSans',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Group Size Selection
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.people,
                              color: AppColors.primary900, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Group Size',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'InstrumentSans',
                              color: AppColors.gray950,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Number of people',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.grayText,
                              fontFamily: 'InstrumentSans',
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: groupSize > 1
                                    ? () {
                                        setState(() {
                                          groupSize--;
                                          _calculateTotalPrice();
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.remove_circle_outline),
                                color: groupSize > 1
                                    ? AppColors.primary900
                                    : AppColors.gray300,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.gray200),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  groupSize.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'InstrumentSans',
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: (selectedDate == null ||
                                        groupSize <
                                            selectedDate!['remaining_capacity'])
                                    ? () {
                                        setState(() {
                                          groupSize++;
                                          _calculateTotalPrice();
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.add_circle_outline),
                                color: (selectedDate == null ||
                                        groupSize <
                                            selectedDate!['remaining_capacity'])
                                    ? AppColors.primary900
                                    : AppColors.gray300,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ),
      ),

      // Bottom Booking Bar
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
        child: SafeArea(
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
                          '\$${totalPrice.toInt()}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'InstrumentSans',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'for $groupSize ${groupSize == 1 ? 'person' : 'people'}',
                          style: const TextStyle(
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
                onPressed: (selectedDate != null && !isBooking)
                    ? _processBooking
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary900,
                  disabledBackgroundColor: AppColors.gray300,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isBooking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
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
      ),
    );
  }
}
