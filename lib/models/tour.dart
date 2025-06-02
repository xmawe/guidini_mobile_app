import 'package:Guidini/models/guide.dart';
import 'package:Guidini/models/location.dart';

class Tour {
  final int? id;
  final int? guideId;
  final int? locationId;
  final int? cityId;
  final String? title;
  final String? description;
  final String? price;
  final int? duration;
  final int? maxGroupSize;
  final String? availabilityStatus;
  final int? isTransportIncluded;
  final int? isFoodIncluded;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Guide? guide;
  final Location? location;

  Tour({
    this.id,
    this.guideId,
    this.locationId,
    this.cityId,
    this.title,
    this.description,
    this.price,
    this.duration,
    this.maxGroupSize,
    this.availabilityStatus,
    this.isTransportIncluded,
    this.isFoodIncluded,
    this.createdAt,
    this.updatedAt,
    this.guide,
    this.location,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      guideId: json['guide_id'],
      locationId: json['location_id'],
      cityId: json['city_id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      duration: json['duration'],
      maxGroupSize: json['max_group_size'],
      availabilityStatus: json['availability_status'],
      isTransportIncluded: json['is_transport_included'],
      isFoodIncluded: json['is_food_included'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      guide: json['guide'] != null ? Guide.fromJson(json['guide']) : null,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guide_id': guideId,
      'location_id': locationId,
      'city_id': cityId,
      'title': title,
      'description': description,
      'price': price,
      'duration': duration,
      'max_group_size': maxGroupSize,
      'availability_status': availabilityStatus,
      'is_transport_included': isTransportIncluded,
      'is_food_included': isFoodIncluded,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'guide': guide?.toJson(),
      'location': location?.toJson(),
    };
  }
}
