// models/tour_date_data.dart
class TourDateData {
  int? dayOfWeek;
  String? startTime;
  String? endTime;

  TourDateData({
    this.dayOfWeek,
    this.startTime,
    this.endTime,
  });

  bool isValid() {
    return dayOfWeek != null &&
        (startTime?.isNotEmpty ?? false) &&
        (endTime?.isNotEmpty ?? false);
  }
}
