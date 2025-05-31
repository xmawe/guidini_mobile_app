import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _tokenKey = 'chat_token';
  
  // Set token for testing purposes
  static Future<void> setTestToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('Test token set: $token');
  }
  
  // Get the current token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Clear the token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('Token cleared');
  }
} 