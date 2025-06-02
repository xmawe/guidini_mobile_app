class User {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? emailVerifiedAt;
  final String? phoneNumber;
  final int? locationId;
  final int? cityId;
  final String? preferences;
  final String? profilePicture;
  final String? lastActivityAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.emailVerifiedAt,
    this.phoneNumber,
    this.locationId,
    this.cityId,
    this.preferences,
    this.profilePicture,
    this.lastActivityAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      phoneNumber: json['phone_number'],
      locationId: json['location_id'],
      cityId: json['city_id'],
      preferences: json['preferences'],
      profilePicture: json['profile_picture'],
      lastActivityAt: json['last_activity_at'],
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
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'phone_number': phoneNumber,
      'location_id': locationId,
      'city_id': cityId,
      'preferences': preferences,
      'profile_picture': profilePicture,
      'last_activity_at': lastActivityAt,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
