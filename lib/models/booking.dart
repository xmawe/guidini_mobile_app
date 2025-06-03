import 'package:guidini/models/tour.dart';

class Booking {
  final int id;
  final String bookingReference;
  final String bookedDate;
  final int groupSize;
  final String totalPrice;
  final String status;
  final Tour tour;
  final String createdAt;
  final String updatedAt;

  Booking({
    required this.id,
    required this.bookingReference,
    required this.bookedDate,
    required this.groupSize,
    required this.totalPrice,
    required this.status,
    required this.tour,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      bookingReference: json['bookingReference'],
      bookedDate: json['bookedDate'],
      groupSize: json['groupSize'],
      totalPrice: json['totalPrice'],
      status: json['status'],
      tour: Tour.fromJson(json['tour']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
