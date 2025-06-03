import 'tour.dart';
import 'dart:convert';

class Guide {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String profilePicture;
  final double rating;
  final List<String> languages;
  final bool isVerified;
  final String biography;
  final DateTime createdAt;
  final DateTime updatedAt;
  List<Tour>? tours;

  // These properties are set after fetching additional data
  DateTime? userCreatedAt;
  String? cityName;
  bool? isOnline;

  Guide({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    required this.rating,
    required this.languages,
    required this.isVerified,
    required this.biography,
    required this.createdAt,  // Guide creation date
    required this.updatedAt,
    this.tours,
    this.userCreatedAt, // optional, can be set later
    this.cityName,
    this.isOnline,
  });

  String get fullName => '$firstName $lastName';

  int get yearsExperience => 
      DateTime.now().difference(createdAt).inDays ~/ 365;
  
  int get reviewsCount => 193;

  // Calculate years since user joined the platform
  String getJoinedTime() {
    if (userCreatedAt == null) return 'Unknown';
    final difference = DateTime.now().difference(userCreatedAt!);
    final years = difference.inDays / 365;
    if (years < 1) {
      final months = difference.inDays / 30;
      if (months < 1) {
        return 'Just joined';
      }
      return '${months.floor()} ${months.floor() == 1 ? 'month' : 'months'} ago';
    }
    return '${years.floor()} ${years.floor() == 1 ? 'year' : 'years'} ago';
  }

  String getExperienceTime() {
    final difference = DateTime.now().difference(createdAt);
    final years = difference.inDays / 365;
    if (years < 1) {
      return 'New guide';
    }
    return '${years.floor()} ${years.floor() == 1 ? 'year' : 'years'}';
  }

  factory Guide.fromJson(Map<String, dynamic> json) {
    List<Tour>? toursList;
    if (json['tours'] != null) {
      toursList = (json['tours'] as List).map((tour) => Tour.fromJson(tour)).toList();
    }

    final userJson = json['user'] ?? json;

    String profilePicture = userJson['profile_picture'] ?? '';
    if (profilePicture.isNotEmpty && !profilePicture.startsWith('http')) {
      profilePicture = 'http://127.0.0.1:8000/storage/$profilePicture';
    }

    // userCreatedAt is not set here, should be set after fetching user data using userId
    return Guide(
      id: json['id'],
      userId: json['user_id'] ?? userJson['id'],
      firstName: userJson['first_name'] ?? 'Unknown',
      lastName: userJson['last_name'] ?? 'Guide',
      profilePicture: profilePicture,
      rating: double.parse(json['rating']?.toString() ?? '0.0'),
      languages: _parseLanguages(json['languages']),
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      biography: json['biography'] ?? '',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      tours: toursList,
    );
  }

  static List<String> _parseLanguages(dynamic languages) {
    if (languages == null) return [];
    if (languages is String) {
      try {
        final decoded = languages.replaceAll("'", '"');
        return List<String>.from(json.decode(decoded));
      } catch (e) {
        return languages.split(',').map((lang) => lang.trim()).toList();
      }
    } else if (languages is List) {
      return languages.map((lang) => lang.toString()).toList();
    }
    return [];
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now().subtract(const Duration(days: 365 * 4));
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        print('Error parsing date: $e');
        return DateTime.now().subtract(const Duration(days: 365 * 4));
      }
    } else if (dateTime is int) {
      return dateTime > 100000000000 
          ? DateTime.fromMillisecondsSinceEpoch(dateTime) 
          : DateTime.fromMillisecondsSinceEpoch(dateTime * 1000);
    }
    return DateTime.now().subtract(const Duration(days: 365 * 4));
  }

  // Set userCreatedAt after fetching user data
  void setUserCreatedAt(DateTime date) {
    userCreatedAt = date;
  }

  // Set city name
  void setCityName(String name) {
    cityName = name;
  }

  // Set online status
  void setOnlineStatus(bool status) {
    isOnline = status;
  }

  static Guide mockGuide() {
    return Guide(
      id: 1,
      userId: 1,
      firstName: 'Youssef',
      lastName: 'El Amrani',
      profilePicture: '',
      rating: 4.5,
      languages: ['Arabic', 'English', 'French'],
      isVerified: true,
      biography: 'Born and raised in the heart of Marrakech, I\'ve spent over 10 years guiding travelers through the historic medina, souks, and palaces. I love sharing hidden gems and the cultural stories behind them.',
      createdAt: DateTime.now().subtract(const Duration(days: 365 * 4)),
      updatedAt: DateTime.now(),
      tours: [
        Tour(
          id: 1,
          title: 'Marrakech Medina & Souks Walking Tour',
          description: 'Experience the vibrant atmosphere of Marrakech medina and souks on this guided walking tour.',
          price: 25.0,
          duration: 3,
          city: 'Marrakech, Morocco',
          guideName: 'Ahmed El Yassifi',
          guideRating: 4.5,
          isTransportIncluded: true,
          isFoodIncluded: true,
          activitiesCount: 4
        ),
        Tour(
          id: 2,
          title: 'Marrakech Medina & Souks Walking Tour',
          description: 'Experience the vibrant atmosphere of Marrakech medina and souks on this guided walking tour.',
          price: 25.0,
          duration: 3,
          city: 'Marrakech, Morocco',
          guideName: 'Ahmed El Yassifi',
          guideRating: 4.5,
          isTransportIncluded: true,
          isFoodIncluded: true,
          activitiesCount: 4
        ),
      ],
      userCreatedAt: DateTime.now().subtract(const Duration(days: 365 * 6)), // For mock only
      cityName: 'Marrakech',
      isOnline: false,
    );
  }
}
