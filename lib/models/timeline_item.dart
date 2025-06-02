class TimelineItem {
  final String startTime;
  final String endTime;
  final String title;
  final String location;
  final String description;
  final String category;
  final String iconAsset;

  TimelineItem({
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.location,
    required this.description,
    required this.category,
    required this.iconAsset,
  });

  String get timeRange => '$startTime - $endTime';
}
