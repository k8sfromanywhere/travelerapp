class FavoritePlace {
  final String id;
  final String name;
  final String type;
  final double lat;
  final double lon;
  final String userId;

  FavoritePlace({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lon,
    required this.userId,
  });

  // Конвертация из Firestore
  factory FavoritePlace.fromFirestore(String id, Map<String, dynamic> data) {
    return FavoritePlace(
      id: id,
      name: data['name'] ?? 'Без названия',
      type: data['type'] ?? 'Неизвестный тип',
      lat: data['lat'] as double,
      lon: data['lon'] as double,
      userId: data['userId'] as String,
    );
  }

  // Конвертация в Map для Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'lat': lat,
      'lon': lon,
      'userId': userId,
    };
  }
}
