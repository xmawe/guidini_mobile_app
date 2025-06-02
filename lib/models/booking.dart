import 'package:Guidini/models/tour.dart';

class Booking {
  final int? id;
  final int? userId;
  final int? tourId;
  final int? tourDateId;
  final DateTime? bookedDate;
  final int? groupSize;
  final String? totalPrice;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Tour? tour;

  Booking({
    this.id,
    this.userId,
    this.tourId,
    this.tourDateId,
    this.bookedDate,
    this.groupSize,
    this.totalPrice,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.tour,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'],
      tourId: json['tour_id'],
      tourDateId: json['tour_date_id'],
      bookedDate: json['booked_date'] != null
          ? DateTime.parse(json['booked_date'])
          : null,
      groupSize: json['group_size'],
      totalPrice: json['total_price'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      tour: json['tour'] != null ? Tour.fromJson(json['tour']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tour_id': tourId,
      'tour_date_id': tourDateId,
      'booked_date': bookedDate?.toIso8601String(),
      'group_size': groupSize,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'tour': tour?.toJson(),
    };
  }
}
