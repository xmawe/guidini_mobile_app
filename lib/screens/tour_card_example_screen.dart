import 'package:flutter/material.dart';
import '../widgets/tour/tour_card.dart';
import '../constants/colors.dart';
import '../models/tour.dart';

class TourCardExampleScreen extends StatelessWidget {
  const TourCardExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create sample tour objects
    final tour1 = Tour(
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
    
    final tour2 = Tour(
      id: 2,
      title: 'Fes Cultural Heritage Tour',
      description: 'Discover the rich cultural heritage of Fes, one of Morocco\'s oldest imperial cities.',
      price: 35.0,
      duration: 5,
      city: 'Fes, Morocco',
      guideName: 'Mohammed Benali',
      guideRating: 4.8,
      isTransportIncluded: false,
      isFoodIncluded: true,
      activitiesCount: 6,
    );
    
    final tour3 = Tour(
      id: 3,
      title: 'Casablanca City Highlights',
      description: 'Explore the vibrant city of Casablanca and its iconic landmarks.',
      price: 30.0,
      duration: 4,
      city: 'Casablanca, Morocco',
      guideName: 'Laila Moussaoui',
      guideRating: 4.6,
      isTransportIncluded: true,
      isFoodIncluded: false,
      activitiesCount: 5,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Card Example'),
        backgroundColor: AppColors.primary800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // Example of the new TourCard design
            TourCard(
              tour: tour1,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tour card tapped')),
                );
              },
            ),
            const SizedBox(height: 20),
            // Add another example with different data
            TourCard(
              tour: tour2,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tour card tapped')),
                );
              },
            ),
            const SizedBox(height: 20),
            // Add a third example
            TourCard(
              tour: tour3,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tour card tapped')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 