class ActivityCategory {
  final int id;
  final String name;
  final String iconAsset;

  ActivityCategory({
    required this.id,
    required this.name,
    required this.iconAsset,
  });

  factory ActivityCategory.fromJson(Map<String, dynamic> json) {
    return ActivityCategory(
      id: json['id'],
      name: json['name'] ?? getCategoryNameById(json['id']),
      iconAsset: getIconAssetById(json['id']),
    );
  }

  // Public method to get category name by ID
  static String getCategoryNameById(int id) {
    switch (id) {
      case 1:
        return 'Exploring';
      case 2:
        return 'Food and drinks';
      case 3:
        return 'Activities';
      case 4:
        return 'Workshops';
      case 5:
        return 'Transport';
      case 6:
        return 'Nature';
      case 7:
        return 'Culture';
      case 8:
        return 'Sports & Adventure';
      case 9:
        return 'Water Activities';
      case 10:
        return 'Cultural Heritage';
      default:
        return 'General';
    }
  }

  // Public method to get icon asset by ID
  static String getIconAssetById(int id) {
    switch (id) {
      case 1:
        return 'assets/icons/explore_icon.png';
      case 2:
        return 'assets/icons/tea_icon.png';
      case 3:
        return 'assets/icons/activity_icon.png';
      case 4:
        return 'assets/icons/workshop_icon.png';
      case 5:
        return 'assets/icons/transport_icon.png';
      case 6:
        return 'assets/icons/group_icon.png';
      case 7:
        return 'assets/icons/eye_icon.png';
      case 8:
        return 'assets/icons/activity_icon.png';
      case 9:
        return 'assets/icons/explore_icon.png';
      case 10:
        return 'assets/icons/workshop_icon.png';
      default:
        return 'assets/icons/explore_icon.png';
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconAsset': iconAsset,
    };
  }

  // Create a copy with different values
  ActivityCategory copyWith({
    int? id,
    String? name,
    String? iconAsset,
  }) {
    return ActivityCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconAsset: iconAsset ?? this.iconAsset,
    );
  }

  @override
  String toString() {
    return 'ActivityCategory(id: $id, name: $name, iconAsset: $iconAsset)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityCategory &&
        other.id == id &&
        other.name == name &&
        other.iconAsset == iconAsset;
  }

  @override
  int get hashCode => Object.hash(id, name, iconAsset);

  // Static list of all available categories
  static List<ActivityCategory> get allCategories {
    return List.generate(10, (index) {
      final id = index + 1;
      return ActivityCategory(
        id: id,
        name: getCategoryNameById(id),
        iconAsset: getIconAssetById(id),
      );
    });
  }

  // Get category by ID with null safety
  static ActivityCategory? getCategoryById(int id) {
    try {
      return ActivityCategory(
        id: id,
        name: getCategoryNameById(id),
        iconAsset: getIconAssetById(id),
      );
    } catch (e) {
      return null;
    }
  }

  // Get categories by name (case insensitive search)
  static List<ActivityCategory> getCategoriesByName(String searchName) {
    return allCategories
        .where((category) =>
            category.name.toLowerCase().contains(searchName.toLowerCase()))
        .toList();
  }
}
