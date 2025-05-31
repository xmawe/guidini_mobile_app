class Tour {
  final int id;
  final String title;
  final String description;
  final double price;
  final int duration;
  final String guideId;
  final String guideName;
  final double guideRating;
  final String location;
  final String city;
  final String imageUrl;
  final bool isTransportIncluded;
  final bool isFoodIncluded;
  final int activitiesCount;
  final String availabilityStatus;
  final int maxGroupSize;

  Tour({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.guideId,
    required this.guideName,
    required this.guideRating,
    required this.location,
    required this.city,
    required this.imageUrl,
    required this.isTransportIncluded,
    required this.isFoodIncluded,
    required this.activitiesCount,
    required this.availabilityStatus,
    this.maxGroupSize = 1,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      duration: json['duration'],
      guideId: json['guide_id'].toString(),
      guideName: json['guide_name'] ?? 'Unknown Guide',
      guideRating: double.parse(json['guide_rating']?.toString() ?? '0.0'),
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      imageUrl: json['image_url'] ?? '',
      isTransportIncluded: json['is_transport_included'] ?? false,
      isFoodIncluded: json['is_food_included'] ?? false,
      activitiesCount: json['activities_count'] ?? 0,
      availabilityStatus: json['availability_status'] ?? 'available',
      maxGroupSize: json['max_group_size'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'duration': duration,
      'guide_id': guideId,
      'guide_name': guideName,
      'guide_rating': guideRating,
      'location': location,
      'city': city,
      'image_url': imageUrl,
      'is_transport_included': isTransportIncluded,
      'is_food_included': isFoodIncluded,
      'activities_count': activitiesCount,
      'availability_status': availabilityStatus,
      'max_group_size': maxGroupSize,
    };
  }

  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (minutes == 0) {
      return '$hours Hour${hours != 1 ? 's' : ''}';
    }
    return '${hours}h ${minutes}m';
  }

  String get formattedPrice => '\$${price.toInt()}';

  bool get isAvailable => availabilityStatus == 'available';
}
