// components/featured_tours_slider.dart
import 'package:flutter/material.dart';
import 'package:guidini/models/tour.dart';
import 'featured_tour_card.dart';

class FeaturedToursSlider extends StatefulWidget {
  final List<Tour> tours;
  final Function(Tour)? onTourTap;

  const FeaturedToursSlider({
    Key? key,
    required this.tours,
    this.onTourTap,
  }) : super(key: key);

  @override
  State<FeaturedToursSlider> createState() => _FeaturedToursSliderState();
}

class _FeaturedToursSliderState extends State<FeaturedToursSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.tours.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: FeaturedTourCard(
                  tour: widget.tours[index],
                  onTap: () => widget.onTourTap?.call(widget.tours[index]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.tours.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
