// screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/tour.dart';
import '../data/sample_data.dart';
import 'package:guidini/widgets/featured_tours_slider.dart';
import 'package:guidini/constants/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Tour> _featuredTours;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // In a real app, these would be API calls
    _featuredTours = SampleData.getFeaturedTours();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SvgPicture.asset(
                  'lib/assets/images/zellij_pattern.svg',
                  fit: BoxFit.fitWidth,
                ),
              ),
              Container(
                color: AppColors.primary800,
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                child: FeaturedToursSlider(
                  tours: _featuredTours,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
