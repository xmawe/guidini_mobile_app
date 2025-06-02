import 'dart:convert';
import 'package:Guidini/screens/booking_item.dart';
import 'package:http/http.dart' as http;
import '../models/tour.dart';
import '../models/booking.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Headers for API requests
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Get headers with authentication token
  static Map<String, String> getAuthHeaders(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // TOUR METHODS

  // Get list of tours
  static Future<List<Tour>> getTours() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tours'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List tourList = data['data']; // if using pagination
        return tourList.map((json) => Tour.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tours: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error loading tours: $e');
      rethrow;
    }
  }

  // Get single tour details
  static Future<Tour> getTourDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tours/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Tour.fromJson(data);
      } else {
        throw Exception('Failed to load tour details: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error loading tour details: $e');
      rethrow;
    }
  }

  // ACTIVITY METHODS

  // Get activities for a specific tour
  static Future<List<Map<String, dynamic>>> getTourActivities(
      int tourId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/activities?tour_id=$tourId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load activities: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error loading activities: $e');
      return [];
    }
  }

  // Get all activities
  static Future<List<Map<String, dynamic>>> getAllActivities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/activities'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load activities: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error loading activities: $e');
      return [];
    }
  }

  // BOOKING METHODS

  // Create a booking
  static Future<Booking> createBooking({
    required String token,
    required int tourId,
    required DateTime bookingDate,
    required int participantsCount,
    String? specialRequests,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: getAuthHeaders(token),
        body: json.encode({
          'tour_id': tourId,
          'booking_date': bookingDate.toIso8601String(),
          'participants_count': participantsCount,
          'special_requests': specialRequests,
        }),
      );

      if (response.statusCode == 201) {
        return Booking.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error creating booking: $e');
      rethrow;
    }
  }

  // Get user's bookings - Returns BookingItem list
  static Future<List<BookingItem>> getMyBookings([String? token]) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-bookings'),
        headers: getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BookingItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error loading user bookings: $e');
      rethrow;
    }
  }

  // Get raw booking data if you still need Booking objects
  static Future<List<Booking>> getMyBookingsRaw([String? token]) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-bookings'),
        headers: getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error loading user bookings: $e');
      rethrow;
    }
  }

  // TOUR IMAGE METHODS

  // Get tour images by tour ID
  static Future<List<TourImage>> getTourImages(int tourId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tours/$tourId/images'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<TourImage> images = [];
          for (var imageData in data['data']) {
            images.add(TourImage.fromJson(imageData));
          }
          return images;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching tour images: $e');
      return [];
    }
  }

  // Get all tour images
  static Future<List<TourImage>> getAllTourImages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tour-images'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<TourImage> images = [];
          for (var imageData in data['data']) {
            images.add(TourImage.fromJson(imageData));
          }
          return images;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching all tour images: $e');
      return [];
    }
  }

  // Get specific tour image
  static Future<TourImage?> getTourImage(int imageId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tour-images/$imageId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return TourImage.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching tour image: $e');
      return null;
    }
  }
}

// TourImage model class
class TourImage {
  final int id;
  final int tourId;
  final String imageUrl;
  final String fullImageUrl;
  final String? tourTitle;
  final DateTime createdAt;
  final DateTime updatedAt;

  TourImage({
    required this.id,
    required this.tourId,
    required this.imageUrl,
    required this.fullImageUrl,
    this.tourTitle,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TourImage.fromJson(Map<String, dynamic> json) {
    return TourImage(
      id: json['id'] ?? 0,
      tourId: json['tour_id'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      fullImageUrl: json['full_image_url'] ?? '',
      tourTitle: json['tour_title'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tour_id': tourId,
      'image_url': imageUrl,
      'full_image_url': fullImageUrl,
      'tour_title': tourTitle,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
