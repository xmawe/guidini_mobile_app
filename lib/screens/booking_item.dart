import 'package:Guidini/models/timeline_item.dart';

class BookingItem {
  final int id;
  final String date;
  final String title;
  final String location;
  final String guide;
  final double rating;
  final double price;
  final String status;
  final bool isWaitingConfirmation;
  final int duration; // in hours
  final bool isTransportIncluded;
  final bool isFoodIncluded;
  final int groupSize;
  final String description;
  final int? tourId; // Add tourId field

  BookingItem({
    required this.id,
    required this.date,
    required this.title,
    required this.location,
    required this.guide,
    required this.rating,
    required this.price,
    required this.status,
    required this.isWaitingConfirmation,
    required this.duration,
    required this.isTransportIncluded,
    required this.isFoodIncluded,
    required this.groupSize,
    required this.description,
    this.tourId, // Make it optional
  });

  // Factory constructor to create from API JSON
  factory BookingItem.fromJson(Map<String, dynamic> json) {
    final tour = json['tour'];
    final guide = tour['guide'];
    final user = guide['user'];
    final location = tour['location'];

    return BookingItem(
      id: json['id'],
      date: _formatDate(json['booked_date']),
      title: tour['title'],
      location: location['label'],
      guide: '${user['first_name']} ${user['last_name']}',
      rating: (guide['rating'] as num).toDouble(),
      price: double.parse(json['total_price'].toString()),
      status: json['status'],
      isWaitingConfirmation: json['status'] == 'pending',
      duration: (tour['duration'] as num).round(),
      isTransportIncluded: tour['is_transport_included'] == 1,
      isFoodIncluded: tour['is_food_included'] == 1,
      groupSize: json['group_size'],
      description: tour['description'],
      tourId: tour['id'], // Add tourId from the tour object
    );
  }

  static String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  // Generate timeline items from description
  List<TimelineItem> generateTimeline() {
    final durationHours = duration;
    final List<TimelineItem> timeline = [];

    if (durationHours >= 1) {
      timeline.add(TimelineItem(
        startTime: '10:00 AM',
        endTime: _addHours('10:00 AM', (durationHours * 0.4).round()),
        title: 'Tour Introduction & ${title.split(' ').take(3).join(' ')}',
        location: location,
        description: description,
        category: 'Exploring',
        iconAsset: 'assets/icons/explore_icon.png',
      ));
    }

    if (durationHours >= 2) {
      final midStart = _addHours('10:00 AM', (durationHours * 0.4).round());
      final midEnd = _addHours('10:00 AM', (durationHours * 0.7).round());

      timeline.add(TimelineItem(
        startTime: midStart,
        endTime: midEnd,
        title: 'Main Activities & Exploration',
        location: 'Various locations in $location',
        description:
            'Experience the highlights of the tour with detailed explanations from your guide.',
        category: 'Activities',
        iconAsset: 'assets/icons/activity_icon.png',
      ));
    }

    if (isFoodIncluded && durationHours >= 2) {
      final foodStart = _addHours('10:00 AM', (durationHours * 0.7).round());
      final foodEnd = _addHours('10:00 AM', durationHours);

      timeline.add(TimelineItem(
        startTime: foodStart,
        endTime: foodEnd,
        title: 'Food & Cultural Experience',
        location: 'Local restaurant/café in $location',
        description:
            'Enjoy traditional local cuisine and learn about local customs and traditions.',
        category: 'Food and drinks',
        iconAsset: 'assets/icons/tea_icon.png',
      ));
    } else if (durationHours >= 3) {
      final endStart = _addHours('10:00 AM', (durationHours * 0.7).round());
      final endEnd = _addHours('10:00 AM', durationHours);

      timeline.add(TimelineItem(
        startTime: endStart,
        endTime: endEnd,
        title: 'Tour Conclusion & Reflection',
        location: location,
        description:
            'Wrap up the tour with final insights and time for questions.',
        category: 'Conclusion',
        iconAsset: 'assets/icons/group_icon.png',
      ));
    }

    return timeline;
  }

  String _addHours(String timeString, int hoursToAdd) {
    try {
      // Parse the time string
      final parts = timeString.split(' ');
      final timePart = parts[0];
      final amPm = parts[1];

      final hourMinute = timePart.split(':');
      int hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);

      // Convert to 24-hour format
      if (amPm == 'PM' && hour != 12) hour += 12;
      if (amPm == 'AM' && hour == 12) hour = 0;

      // Add hours
      hour += hoursToAdd;

      // Handle overflow
      hour = hour % 24;

      // Convert back to 12-hour format
      String newAmPm = 'AM';
      if (hour >= 12) {
        newAmPm = 'PM';
        if (hour > 12) hour -= 12;
      }
      if (hour == 0) hour = 12;

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $newAmPm';
    } catch (e) {
      // Return a default time if parsing fails
      return '${10 + hoursToAdd}:00 AM';
    }
  }

  // Helper method to create a copy with different values
  BookingItem copyWith({
    int? id,
    String? date,
    String? title,
    String? location,
    String? guide,
    double? rating,
    double? price,
    String? status,
    bool? isWaitingConfirmation,
    int? duration,
    bool? isTransportIncluded,
    bool? isFoodIncluded,
    int? groupSize,
    String? description,
    int? tourId,
  }) {
    return BookingItem(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      location: location ?? this.location,
      guide: guide ?? this.guide,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      status: status ?? this.status,
      isWaitingConfirmation:
          isWaitingConfirmation ?? this.isWaitingConfirmation,
      duration: duration ?? this.duration,
      isTransportIncluded: isTransportIncluded ?? this.isTransportIncluded,
      isFoodIncluded: isFoodIncluded ?? this.isFoodIncluded,
      groupSize: groupSize ?? this.groupSize,
      description: description ?? this.description,
      tourId: tourId ?? this.tourId,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'title': title,
      'location': location,
      'guide': guide,
      'rating': rating,
      'price': price,
      'status': status,
      'isWaitingConfirmation': isWaitingConfirmation,
      'duration': duration,
      'isTransportIncluded': isTransportIncluded,
      'isFoodIncluded': isFoodIncluded,
      'groupSize': groupSize,
      'description': description,
      'tourId': tourId,
    };
  }

  @override
  String toString() {
    return 'BookingItem(id: $id, title: $title, guide: $guide, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
