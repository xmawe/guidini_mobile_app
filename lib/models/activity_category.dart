class ActivityCategory {
  final int id;
  final String name;

  ActivityCategory({required this.id, required this.name});

  factory ActivityCategory.fromJson(Map<String, dynamic> json) {
    return ActivityCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}