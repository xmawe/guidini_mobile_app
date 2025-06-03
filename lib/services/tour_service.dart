import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tour.dart';
import '../models/guide.dart';
import '../services/token_service.dart';
import '../services/guide_service.dart';
import '../services/service_provider.dart';

class TourService {
  // In a real app, this should be determined by the environment
  // and use a platform-specific approach for emulators
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Helper method to get auth token
  Future<String?> _getAuthToken() async {
    return await TokenService.getToken();
  }

  // Get all tours
  Future<List<Tour>> getTours({String? location}) async {
    try {
      String url = '$baseUrl/tours';
      if (location != null && location.isNotEmpty && location != 'Select Location') {
        url += '?location=$location';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Tour.fromJson(json)).toList();
      } else {
        print('Failed to load tours: ${response.statusCode}');
        print('Response body: ${response.body}');
        return _getMockTours();
      }
    } catch (e) {
      print('Error fetching tours: $e');
      return _getMockTours();
    }
  }

  // Get guide by id
  Future<Guide> getGuideById(int id) async {
    try {
      print('Fetching guide with ID: $id from $baseUrl/guides/$id');
      
      // First get the guide's basic info
      final response = await http.get(Uri.parse('$baseUrl/guides/$id'));
      
      print('Guide API response status: ${response.statusCode}');
      print('Guide API response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final guideData = json.decode(response.body)['data'];
        
        // Create the guide object
        final guide = Guide.fromJson(guideData);
        
        // Then get the guide's tours
        try {
          final toursList = await getToursByGuideId(id);
          guide.tours = toursList;
        } catch (e) {
          print('Failed to load tours for guide, using mock data: $e');
          guide.tours = _getMockTours();
        }
        
        // Get the guide service to enhance the guide with user data
        final guideService = ServiceProvider().getGuideService();
        return await guideService.enhanceGuideData(guide);
      } else {
        print('Failed to load guide, using mock data: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        // For development/testing, return a mock guide with tours
        final mockGuide = Guide.mockGuide();
        mockGuide.tours = _getMockTours();
        return mockGuide;
      }
    } catch (e) {
      print('Error fetching guide: $e');
      
      // For development/testing, return a mock guide with tours
      final mockGuide = Guide.mockGuide();
      mockGuide.tours = _getMockTours();
      return mockGuide;
    }
  }
  
  // Get tours by guide id
  Future<List<Tour>> getToursByGuideId(int guideId) async {
    try {
      print('Fetching tours for guide with ID: $guideId from $baseUrl/guides/$guideId/tours');
      
      final response = await http.get(Uri.parse('$baseUrl/guides/$guideId/tours'));
      
      print('Tours API response status: ${response.statusCode}');
      print('Tours API response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Tour.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        // If guide has no tours, return empty list
        print('No tours found for guide, returning empty list');
        return [];
      } else {
        print('Failed to load guide tours, using mock data: ${response.statusCode}');
        return _getMockTours();
      }
    } catch (e) {
      print('Error fetching guide tours: $e');
      return _getMockTours();
    }
  }
  
  // Helper method to get mock tours for testing
  List<Tour> _getMockTours() {
    return [
      Tour(
        id: 1,
        title: 'Marrakech Medina Tour',
        description: 'Explore the ancient medina of Marrakech with a local expert',
        price: 35.00,
        duration: 3,
        city: 'Marrakech',
        guideName: 'Local Guide',
        guideRating: 4.5,
        isTransportIncluded: true,
        isFoodIncluded: true,
        activitiesCount: 4,
      ),
      Tour(
        id: 2,
        title: 'Atlas Mountains Day Trip',
        description: 'Breathtaking views of the Atlas mountains with Berber village visits',
        price: 85.00,
        duration: 8,
        city: 'Marrakech',
        guideName: 'Local Guide',
        guideRating: 4.7,
        isTransportIncluded: true,
        isFoodIncluded: true,
        activitiesCount: 6,
      ),
    ];
  }
  
  // Contact guide to initiate a chat
  Future<Map<String, dynamic>> contactGuide(int guideId, String message) async {
    try {
      print('Creating or getting chat room with user ID: $guideId');
      
      // Get auth token
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      // Get current user information
      final currentUserData = await _getCurrentUserData(token);
      if (currentUserData != null && currentUserData['id'] == guideId) {
        throw Exception('Cannot start a conversation with yourself');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/chat/rooms'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_id': guideId,
        }),
      );
      
      print('Chat room API response status: ${response.statusCode}');
      print('Chat room API response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'chat_room_id': data['chat_room_id'],
          'is_new': data['is_new'] ?? false
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Not authorized. Please check your authentication token.');
      } else {
        throw Exception('Failed to contact guide: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error contacting guide: $e');
      
      // Don't return mock data if it's a self-chat error
      if (e.toString().contains('Cannot start a conversation with yourself')) {
        return {
          'success': false,
          'error': e.toString()
        };
      }
      
      // Return mock data for testing
      return {
        'success': true,
        'chat_room_id': 1,
        'is_new': false
      };
    }
  }
  
  // Helper method to get current user data
  Future<Map<String, dynamic>?> _getCurrentUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting current user data: $e');
      return null;
    }
  }
} 