import 'package:flutter/material.dart';
import 'package:guidini/constants/colors.dart';
import 'package:guidini/models/tour.dart';
import 'package:guidini/screens/public/tour_detail_screen.dart';
import 'package:guidini/models/tour.dart';

class TourCardWidget extends StatelessWidget {
  final Tour tour;

  const TourCardWidget({
    super.key,
    required this.tour,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Navigate to tour detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TourDetailScreen(tourId: tour.id),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
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
                          ),
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: tour.imageUrl != null
                                ? Image.network(
                                    tour.imageUrl!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.gray050,
                                        child: const Icon(Icons.image,
                                            size: 40, color: AppColors.gray100),
                                      );
                                    },
                                  )
                                : Container(
                                    color: AppColors.gray050,
                                    child: const Icon(Icons.image,
                                        size: 40, color: AppColors.gray100),
                                  ),
                          ),
                        ),
                        // Only show rating badge if tour rating is greater than 0
                        if (tour.tourRating > 0)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    tour.tourRating.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary900,
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
                            tour.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'InstrumentSans',
                              color: AppColors.gray950,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tour.location,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.grayText,
                              fontFamily: 'InstrumentSans',
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Guided by',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.grayText,
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
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary950,
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
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(Icons.check,
                                                size: 8);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tour.guideName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary900,
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
                                tour.guideRating.toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary900,
                                  fontFamily: 'InstrumentSans',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tour.city,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryRed,
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
                          _buildInfoChip(
                              Icons.access_time, '${tour.duration} Hours'),
                          if (tour.isFoodIncluded)
                            _buildInfoChip(
                                Icons.restaurant_menu, 'Food Included'),
                          _buildInfoChip(Icons.location_on_outlined,
                              '${tour.activitiesCount} Activities'),
                          if (tour.isTransportIncluded)
                            _buildInfoChip(Icons.directions_car_outlined,
                                'Transport Included'),
                        ],
                      ),
                    ),

                    // RIGHT: Price section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Starts from',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.gray400,
                            fontFamily: 'InstrumentSans',
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${tour.price}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'InstrumentSans',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              '/',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grayText,
                                fontFamily: 'InstrumentSans',
                              ),
                            ),
                            const SizedBox(width: 2),
                            Image.asset(
                              'assets/images/icons/ic_person.png',
                              width: 12,
                              height: 12,
                              color: AppColors.gray700,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person,
                                    size: 12, color: AppColors.gray700);
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
        ));
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray050,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.gray300),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.gray700,
              fontFamily: 'InstrumentSans',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
