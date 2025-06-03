import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'token_service.dart';

class AuthService {
  // In a real app, this should be determined by the environment
  // and use a platform-specific approach for emulators
  static String get _baseUrl {
    return 'http://127.0.0.1:8000/api';
  }
  
  final Dio _dio = Dio();

  AuthService() {
    _initializeDio();
  }

  Future<void> _initializeDio() async {
    _dio.options.baseUrl = _baseUrl;
    print('Using API base URL: ${_dio.options.baseUrl}');
    
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    // Get token from SharedPreferences and set it if exists
    final token = await TokenService.getToken();
    if (token != null) {
      setToken(token);
      print('Token loaded from storage: $token');
    } else {
      print('No token found in storage');
    }
  }

  // Token management
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print('Token set in headers: Bearer $token');
  }

  // Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      print('Login API Response: ${response.data}');
      
      // Extract the data from the response
      final responseData = response.data;
      
      if (responseData is Map<String, dynamic> && 
          responseData.containsKey('success') && 
          responseData['success'] == true) {
        
        final data = responseData['data'];
        if (data is Map<String, dynamic> && data.containsKey('token')) {
          final token = data['token'];
          
          // Save token to shared preferences
          await TokenService.setTestToken(token);
          
          // Set token in headers for future requests
          setToken(token);
          
          // Check if user is online
          bool isOnline = false;
          if (data.containsKey('user') && 
              data['user'] is Map<String, dynamic> && 
              data['user'].containsKey('is_online')) {
            isOnline = data['user']['is_online'] == true;
          }
          
          return {
            'success': true,
            'token': token,
            'user': data['user'],
            'is_online': isOnline,
          };
        }
      }
      
      // If we get here, something went wrong with the response format
      return {
        'success': false,
        'message': 'Invalid response format',
      };
    } catch (e) {
      print('Login error: $e');
      
      String errorMessage = 'Login failed';
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          errorMessage = 'Invalid email or password';
        } else if (e.response?.data is Map<String, dynamic> && 
                  e.response?.data.containsKey('message')) {
          errorMessage = e.response?.data['message'];
        }
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }
  
  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }
      
      // Set token in headers for this request
      _dio.options.headers['Authorization'] = 'Bearer $token';
      
      final response = await _dio.post('/auth/logout');
      
      // Clear token regardless of response
      await TokenService.clearToken();
      
      return {
        'success': true,
        'message': 'Successfully logged out',
      };
    } catch (e) {
      print('Logout error: $e');
      
      // Clear token even if API call fails
      await TokenService.clearToken();
      
      return {
        'success': true, // Return success anyway since we cleared the token
        'message': 'Logged out locally',
      };
    }
  }
  
  // Update user's last activity to mark as online
  Future<Map<String, dynamic>> updateLastActivity() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }
      
      // Set token in headers for this request
      _dio.options.headers['Authorization'] = 'Bearer $token';
      
      final response = await _dio.post('/chat/activity');
      
      return {
        'success': true,
        'message': 'Last activity updated',
      };
    } catch (e) {
      print('Update last activity error: $e');
      
      return {
        'success': false,
        'message': 'Failed to update last activity',
      };
    }
  }
} 