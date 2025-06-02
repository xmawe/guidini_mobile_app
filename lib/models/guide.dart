import 'package:Guidini/models/user.dart';

class Guide {
  final int? id;
  final int? userId;
  final List<String>? languages;
  final bool? isVerified;
  final double? rating;
  final String? biography;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? user;

  Guide({
    this.id,
    this.userId,
    this.languages,
    this.isVerified,
    this.rating,
    this.biography,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: json['id'],
      userId: json['user_id'],
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : null,
      isVerified: json['is_verified'],
      rating: json['rating']?.toDouble(),
      biography: json['biography'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'languages': languages,
      'is_verified': isVerified,
      'rating': rating,
      'biography': biography,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}
