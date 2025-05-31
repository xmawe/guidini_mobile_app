// data/sample_data.dart
import '../models/tour.dart';

class SampleData {
  static List<Tour> getFeaturedTours() {
    return [
      Tour(
        id: 1,
        title: "EL MEDINA EL KDIMA TOUR WITH AHMED",
        description: "Explore the ancient medina with a local expert",
        price: 45.0,
        duration: 180, // 3 hours
        guideId: "1",
        guideName: "Ahmed El Yassifi",
        guideRating: 4.5,
        location: "Marrakech",
        city: "Morocco",
        imageUrl:
            "https://images.unsplash.com/photo-1539650116574-75c0c6d04e3d?w=400",
        isTransportIncluded: true,
        isFoodIncluded: true,
        activitiesCount: 4,
        availabilityStatus: "available",
      ),
      Tour(
        id: 2,
        title: "EL MEDINA EL KDIMA TOUR WITH AHMED",
        description: "Discover hidden gems in the old city",
        price: 35.0,
        duration: 240, // 4 hours
        guideId: "1",
        guideName: "Ahmed El Yassifi",
        guideRating: 4.5,
        location: "Marrakech",
        city: "Morocco",
        imageUrl:
            "https://images.unsplash.com/photo-1543429024-1f4d0a0e1e03?w=400",
        isTransportIncluded: true,
        isFoodIncluded: false,
        activitiesCount: 3,
        availabilityStatus: "available",
      ),
    ];
  }

  static List<Tour> getNearbyTours() {
    return [
      Tour(
        id: 3,
        title: "Marrakech Medina & Souks Walking Tour",
        description: "Experience the vibrant souks and traditional markets",
        price: 25.0,
        duration: 180,
        guideId: "1",
        guideName: "Ahmed El Yassifi",
        guideRating: 4.5,
        location: "Marrakech",
        city: "Morocco",
        imageUrl:
            "https://images.unsplash.com/photo-1570099348162-d3e6a5b0b2a2?w=400",
        isTransportIncluded: true,
        isFoodIncluded: true,
        activitiesCount: 4,
        availabilityStatus: "available",
      ),
      Tour(
        id: 4,
        title: "Marrakech Medina & Souks Walking Tour",
        description: "Immerse yourself in local culture and history",
        price: 25.0,
        duration: 180,
        guideId: "1",
        guideName: "Ahmed El Yassifi",
        guideRating: 4.5,
        location: "Marrakech",
        city: "Morocco",
        imageUrl:
            "https://images.unsplash.com/photo-1544161513-0179dfcb9719?w=400",
        isTransportIncluded: true,
        isFoodIncluded: true,
        activitiesCount: 4,
        availabilityStatus: "available",
      ),
    ];
  }
}
