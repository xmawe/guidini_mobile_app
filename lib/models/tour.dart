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
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: double.parse(json['price'].toString()), // Parse string to double
      duration: json['duration'],
      city: json['city']['name'] ?? 'Unknown City',
      guideName: json['guide']['name'] ?? 'Unknown Guide',
      guideRating: double.parse(json['guide']['rating'].toString() ?? '0.0'),
      isTransportIncluded: json['is_transport_included'] == 1,
      isFoodIncluded: json['is_food_included'] == 1,
      activitiesCount: json['activities_count'] ?? 0,
    );
  }
}