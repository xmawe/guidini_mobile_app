class City {
  final int id;
  final String name;
  final String? country;
  final String? region;

  City({
    required this.id,
    required this.name,
    this.country,
    this.region,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      country: json['country'],
      region: json['region'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'region': region,
    };
  }
}
