import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class RouteModel {
  final String id;
  final String name;
  final List<LatLng> waypoints;
  final Timestamp createdAt;

  RouteModel({
    required this.id,
    required this.name,
    required this.waypoints,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'waypoints': waypoints
          .map((point) => GeoPoint(point.latitude, point.longitude))
          .toList(),
      'createdAt': createdAt,
    };
  }

  factory RouteModel.fromMap(Map<String, dynamic> map, String id) {
    return RouteModel(
      id: id,
      name: map['name'] as String,
      waypoints: (map['waypoints'] as List).map((point) {
        final geoPoint = point as GeoPoint;
        return LatLng(geoPoint.latitude, geoPoint.longitude);
      }).toList(),
      createdAt: map['createdAt'] as Timestamp,
    );
  }
}
