import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/guide.dart';
import 'token_service.dart';

class GuideService {
  // In a real app, this should be determined by the environment
  // and use a platform-specific approach for emulators
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Helper method to get auth token
  Future<String?> _getAuthToken() async {
    return await TokenService.getToken();
  }

  // Fetch user data for a guide
  Future<Map<String, dynamic>> getUserData(int userId) async {
    try {
      print('Fetching user data for user ID: $userId');
      
      // Get auth token for authenticated endpoints
      final token = await _getAuthToken();
      
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      // Add token if available
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final url = Uri.parse('$baseUrl/users/$userId');
      final response = await http.get(url, headers: headers);
      
      print('User API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Successfully fetched user data for user ID: $userId');
        return {
          'success': true, 
          'data': data
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Authentication error when fetching user data: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Authentication required',
          'status': response.statusCode
        };
      } else {
        print('Failed to fetch user data: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'error': 'Failed to fetch user data',
          'status': response.statusCode,
          'body': response.body
        };
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }
  
  // Fetch city data by ID
  Future<Map<String, dynamic>> getCityData(int cityId) async {
    try {
      print('Fetching city data for city ID: $cityId');
      
      final url = Uri.parse('$baseUrl/cities/$cityId');
      final response = await http.get(url);
      
      print('City API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data
        };
      } else {
        print('Failed to fetch city data: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'error': 'Failed to fetch city data',
          'status': response.statusCode
        };
      }
    } catch (e) {
      print('Error fetching city data: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }
  
  // Enhance guide data with user info and city data
  Future<Guide> enhanceGuideData(Guide guide) async {
    try {
      // Fetch user data
      final userResult = await getUserData(guide.userId);
      
      if (userResult['success'] == true) {
        final userData = userResult['data'];
        
        // Set user creation date
        final createdAtStr = userData['created_at'];
        if (createdAtStr != null) {
          guide.setUserCreatedAt(DateTime.parse(createdAtStr));
        }
        
        // Set online status
        guide.isOnline = userData['is_online'] ?? false;
        
        // Set city name if available
        if (userData['city'] != null) {
          guide.cityName = userData['city']['name'];
        } else if (userData['city_id'] != null) {
          // Fetch city data separately
          final cityResult = await getCityData(userData['city_id']);
          if (cityResult['success'] == true) {
            guide.cityName = cityResult['data']['name'] ?? 'Unknown City';
          } else {
            guide.cityName = 'Unknown City';
          }
        }
      }
      
      return guide;
    } catch (e) {
      print('Error enhancing guide data: $e');
      return guide; // Return original guide if enhancement fails
    }
  }
} 