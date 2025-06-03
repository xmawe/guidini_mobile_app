import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:guidini/constants/colors.dart';
import 'package:guidini/models/activity_data.dart';
import 'package:guidini/models/tour_date_data.dart';

class ReviewStep extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String duration;
  final String maxGroupSize;
  final List<dynamic> cities;
  final int? selectedCityId;
  final String availabilityStatus;
  final bool isTransportIncluded;
  final bool isFoodIncluded;
  final List<ActivityData> activities;
  final List<TourDateData> tourDates;
  final List<XFile> selectedImages;
  final List<dynamic> activityCategories;

  const ReviewStep({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.maxGroupSize,
    required this.cities,
    required this.selectedCityId,
    required this.availabilityStatus,
    required this.isTransportIncluded,
    required this.isFoodIncluded,
    required this.activities,
    required this.tourDates,
    required this.selectedImages,
    required this.activityCategories,
  }) : super(key: key);

  String _getCityName() {
    if (selectedCityId == null) return 'Not selected';
    final city = cities.firstWhere(
      (city) => city['id'] == selectedCityId,
      orElse: () => null,
    );
    return city != null ? city['name'] : 'Unknown';
  }

  String _getCategoryName(int categoryId) {
    final category = activityCategories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => null,
    );
    return category != null ? category['name'] : 'Unknown';
  }

  String _getDayName(int dayOfWeek) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[dayOfWeek - 1];
  }

  @override
  Widget build(BuildContext context) {
    final validActivities =
        activities.where((activity) => activity.isValid()).toList();
    final validDates = tourDates.where((date) => date.isValid()).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image Placeholder with Tour Header
          _buildHeroSection(),

          const SizedBox(height: 24),

          // Tour Title and Rating
          _buildTourHeader(),

          const SizedBox(height: 20),

          // Quick Info Bar
          _buildQuickInfoBar(),

          const SizedBox(height: 28),

          // Activities Timeline
          _buildActivitiesSection(validActivities),

          const SizedBox(height: 28),

          // Schedule Section
          _buildScheduleSection(validDates),

          const SizedBox(height: 28),

          // Details Grid
          _buildDetailsGrid(),

          const SizedBox(height: 28),

          // Description Section
          _buildDescriptionSection(),

          const SizedBox(height: 28),

          // Images Gallery
          _buildImageGallery(),

          const SizedBox(height: 28),

          // Price Summary
          _buildPriceSummary(),

          const SizedBox(height: 20),

          // Ready to Publish Section
          _buildReadySection(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColors.primary800.withOpacity(0.8),
            AppColors.primary600.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.gray050,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: selectedImages.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Placeholder for main image
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.landscape,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                  // Overlay gradient
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.primary800.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: Colors.white70,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No images selected',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTourHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   children: [
        //     Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        //       decoration: BoxDecoration(
        //         color: Colors.amber,
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       child: Row(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           const Icon(Icons.star, size: 14, color: Colors.white),
        //           const SizedBox(width: 4),
        //           const Text(
        //             'New',
        //             style: TextStyle(
        //               color: Colors.white,
        //               fontSize: 12,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              _getCityName(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickInfoBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray050),
      ),
      child: Row(
        children: [
          // _buildQuickInfoItem(Icons.access_time, '$duration Hours'),
          // _buildQuickInfoDivider(),
          // _buildQuickInfoItem(Icons.group, '$maxGroupSize People'),
          // _buildQuickInfoDivider(),
          _buildQuickInfoItem(
              Icons.local_activity, '${activities.length} Activities'),
          if (isTransportIncluded || isFoodIncluded) ...[
            _buildQuickInfoDivider(),
            if (isTransportIncluded)
              _buildQuickInfoItem(Icons.directions_car, 'Transport'),
            _buildQuickInfoDivider(),
            if (isFoodIncluded) _buildQuickInfoItem(Icons.restaurant, 'Food'),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.primary800),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoDivider() {
    return Container(
      height: 20,
      width: 1,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildActivitiesSection(List<ActivityData> validActivities) {
    if (validActivities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Itinerary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...validActivities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          return _buildModernActivityCard(
              activity, index + 1, index == validActivities.length - 1);
        }).toList(),
      ],
    );
  }

  Widget _buildModernActivityCard(
      ActivityData activity, int stepNumber, bool isLast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary800, AppColors.primary600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary800.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    stepNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary800.withOpacity(0.3),
                        Colors.grey[200]!,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Activity content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        activity.title ?? 'Activity',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary800.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${activity.duration}h',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (activity.locationLabel?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            activity.locationLabel!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    activity.description ?? 'No description',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getCategoryName(activity.categoryId ?? 0),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(List<TourDateData> validDates) {
    if (validDates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...validDates.map((date) => _buildModernScheduleCard(date)).toList(),
      ],
    );
  }

  Widget _buildModernScheduleCard(TourDateData date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Text(
            _getDayName(date.dayOfWeek ?? 1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${date.startTime} - ${date.endTime}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tour Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Duration',
                  '$duration hours',
                  Icons.access_time,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  'Group Size',
                  '$maxGroupSize people',
                  Icons.group,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Status',
                  availabilityStatus.toUpperCase(),
                  Icons.check_circle,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  'Activities',
                  '${activities.length} included',
                  Icons.local_activity,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This Tour',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Gallery',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary800.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${selectedImages.length} photos',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          selectedImages.isEmpty
              ? Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey[300]!, style: BorderStyle.solid),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 32,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No images selected',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 32,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total price',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary800,
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    'People',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    maxGroupSize,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey[300],
              ),
              Column(
                children: [
                  Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$duration hours',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ready to Create',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your tour is complete and ready to be published',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
