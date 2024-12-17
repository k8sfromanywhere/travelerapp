class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final double lat;
  final double lon;
  final String userId;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.lat,
    required this.lon,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cuisine': cuisine,
      'lat': lat,
      'lon': lon,
      'userId': userId,
    };
  }

  static Restaurant fromMap(String id, Map<String, dynamic> map) {
    return Restaurant(
      id: id,
      name: map['name'] as String,
      cuisine: map['cuisine'] as String,
      lat: map['lat'] as double,
      lon: map['lon'] as double,
      userId: map['userId'] as String,
    );
  }
}
