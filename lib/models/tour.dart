class Tour {
  final int id;
  final String title;
  final String description;
  final double price;
  final int duration;
  final String city;
  final String guideName;
  final double guideRating;
  final bool isTransportIncluded;
  final bool isFoodIncluded;
  final int activitiesCount;
  final int maxGroupSize;
  final String availabilityStatus;

  Tour({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.city,
    required this.guideName,
    required this.guideRating,
    required this.isTransportIncluded,
    required this.isFoodIncluded,
    required this.activitiesCount,
    this.maxGroupSize = 10,
    this.availabilityStatus = 'available',
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      title: json['title'] ?? 'Unknown Tour',
      description: json['description'] ?? 'No description available',
      price: double.parse((json['price'] ?? 0).toString()), 
      duration: int.parse((json['duration'] ?? 0).toString()),
      city: json['city'] ?? 'Unknown City',
      guideName: json['guide_name'] ?? 'Unknown Guide',
      guideRating: double.parse((json['guide_rating'] ?? 0).toString()),
      isTransportIncluded: json['is_transport_included'] == 1 || json['is_transport_included'] == true,
      isFoodIncluded: json['is_food_included'] == 1 || json['is_food_included'] == true,
      activitiesCount: json['activities_count'] ?? 0,
      maxGroupSize: json['max_group_size'] ?? 10,
      availabilityStatus: json['availability_status'] ?? 'available',
    );
  }
}