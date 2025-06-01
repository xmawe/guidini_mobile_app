import 'package:flutter/material.dart';
import '../widgets/tour/tour_card_simple.dart';
import '../models/tour.dart';

class SimpleTourCardExample extends StatelessWidget {
  const SimpleTourCardExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a sample tour for display
    final sampleTour = Tour(
      id: 1,
      title: 'Marrakech Medina & Souks Walking Tour',
      description: 'Experience the vibrant atmosphere of Marrakech medina and souks on this guided walking tour.',
      price: 25.0,
      duration: 3,
      city: 'Marrakesh, Morocco',
      guideName: 'Ahmed El Yassifi',
      guideRating: 4.5,
      isTransportIncluded: true,
      isFoodIncluded: true,
      activitiesCount: 4,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Card'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the simple tour card
            TourCardSimple(
              tour: sampleTour,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tour card tapped')),
                );
              },
            ),
            const SizedBox(height: 24),
            // Description of the card design
            Text(
              'Tour Card Design',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This tour card design follows the specifications from the provided image, featuring:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Large image header with rating badge'),
            _buildBulletPoint('Tour title and location information'),
            _buildBulletPoint('Guide information with profile picture and rating'),
            _buildBulletPoint('Feature chips showing duration, activities, and amenities'),
            _buildBulletPoint('Price information with per-person indicator'),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
} 