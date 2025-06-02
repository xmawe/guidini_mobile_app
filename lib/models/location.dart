class Location {
  final int? id;
  final String? longitude;
  final String? latitude;
  final String? label;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Location({
    this.id,
    this.longitude,
    this.latitude,
    this.label,
    this.createdAt,
    this.updatedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      label: json['label'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'longitude': longitude,
      'latitude': latitude,
      'label': label,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
