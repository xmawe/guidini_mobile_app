import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/tour.dart';

/// A widget that displays a single tour card using the design from the home screen.
class TourCard extends StatelessWidget {
  final Tour tour;
  final VoidCallback? onTap;

  const TourCard({
    Key? key,
    required this.tour,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: Container(
                          width: 120,
                          height: 120,
                          color: AppColors.gray100,
                          child: Icon(Icons.image, size: 40, color: AppColors.gray400),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: AppColors.primary800,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "${tour.guideRating}",
                                style: TextStyle(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tour.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'InstrumentSans',
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tour.city.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.gray500,
                            fontFamily: 'InstrumentSans',
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Guided by',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.gray500,
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
                                    color: AppColors.primary950,
                                  ),
                                ),
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
                                      child: Icon(
                                        Icons.check,
                                        size: 8,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tour.guideName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary900,
                                fontFamily: 'InstrumentSans',
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "${tour.guideRating}",
                              style: TextStyle(
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
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary500,
                            fontFamily: 'InstrumentSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildInfoChip(Icons.access_time, '${tour.duration} Hours'),
                        if (tour.isFoodIncluded)
                          _buildInfoChip(Icons.restaurant, 'Food Included'),
                        _buildInfoChip(Icons.map, '${tour.activitiesCount} Activities'),
                        if (tour.isTransportIncluded)
                          _buildInfoChip(Icons.directions_car, 'Transport Included'),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Starts from',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.gray500,
                          fontFamily: 'InstrumentSans',
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${tour.price}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'InstrumentSans',
                            ),
                          ),
                          Text(
                            '/',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray500,
                              fontFamily: 'InstrumentSans',
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.person,
                            size: 12,
                            color: AppColors.gray700,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              if (onTap != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InstrumentSans',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.gray600,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
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
