class Tour {
  final int id;
  final String title;
  final String description;
  final double price;
  final int duration;
  final String city;
  final String location;
  final int guideId; // Added guideId field
  final String guideName;
  final double guideRating;
  final double tourRating;
  final bool isTransportIncluded;
  final bool isFoodIncluded;
  final int activitiesCount;
  final String? imageUrl;

  Tour({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.city,
    required this.location,
    required this.guideId, // Added to constructor
    required this.guideName,
    required this.guideRating,
    required this.tourRating,
    required this.isTransportIncluded,
    required this.isFoodIncluded,
    required this.activitiesCount,
    this.imageUrl,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    // Get the first activity's location label
    String locationLabel = 'Unknown Location';
    if (json['activities'] != null &&
        json['activities'].isNotEmpty &&
        json['activities'][0]['location'] != null) {
      locationLabel =
          json['activities'][0]['location']['label'] ?? 'Unknown Location';
    }

    return Tour(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      duration: json['duration'],
      city: json['city']['name'] ?? 'Unknown City',
      location: locationLabel,
      guideId: json['guide']['id'], // Extract guideId from JSON
      guideName:
          '${json['guide']['user']['firstName']} ${json['guide']['user']['lastName']}',
      guideRating: double.parse(json['guide']['rating'].toString()),
      tourRating: double.parse(json['rating'].toString()),
      isTransportIncluded: json['isTransportIncluded'] == 1,
      isFoodIncluded: json['isFoodIncluded'] == 1,
      activitiesCount: json['activityCount'] ?? 0,
      imageUrl: json['tourImages'] != null && json['tourImages'].isNotEmpty
          ? json['tourImages'][0]['imageUrl']
          : null,
    );
  }
}
