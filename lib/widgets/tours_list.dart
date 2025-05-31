// components/tours_list.dart
import 'package:flutter/material.dart';
import '../models/tour.dart';
import 'tour_card.dart';

class ToursList extends StatelessWidget {
  final List<Tour> tours;
  final Function(Tour)? onTourTap;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const ToursList({
    Key? key,
    required this.tours,
    this.onTourTap,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      itemCount: tours.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TourCard(
            tour: tours[index],
            onTap: () => onTourTap?.call(tours[index]),
          ),
        );
      },
    );
  }
}
