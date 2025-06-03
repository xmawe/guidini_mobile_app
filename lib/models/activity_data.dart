class ActivityData {
  String? title;
  String? description;
  int? categoryId;
  int? duration;
  String? locationLabel;
  String? latitude;
  String? longitude;

  ActivityData({
    this.title,
    this.description,
    this.categoryId,
    this.duration,
    this.locationLabel,
    this.latitude,
    this.longitude,
  });

  bool isValid() {
    return (title?.isNotEmpty ?? false) &&
        (description?.isNotEmpty ?? false) &&
        categoryId != null &&
        duration != null &&
        locationLabel?.isNotEmpty == true;
  }
}
