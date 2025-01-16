class Attraction {
  final String name;
  final String description;
  final double lat;
  final double lon;

  Attraction({
    required this.name,
    required this.description,
    required this.lat,
    required this.lon,
  });

  factory Attraction.fromJson(Map<String, dynamic> json) {
    return Attraction(
      name: json['tags']['name'] ?? 'Без имени',
      description: json['tags']['description'] ?? 'Описание недоступно',
      lat: json['lat'] ?? 0.0,
      lon: json['lon'] ?? 0.0,
    );
  }
}
