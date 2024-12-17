import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:travelerapp/features/routes/data/route_model.dart';

class FirebaseService {
  static final _firestore = FirebaseFirestore.instance;
  static final _routesCollection = _firestore.collection('routes');

  static Future<void> saveRoute(String name, List<LatLng> waypoints) async {
    final data = {
      'name': name,
      'waypoints': waypoints
          .map((point) => GeoPoint(point.latitude, point.longitude)) // GeoPoint
          .toList(),
      'createdAt': Timestamp.now(),
    };
    await _routesCollection.add(data);
  }

  static Future<List<RouteModel>> loadRoutes() async {
    final querySnapshot =
        await _routesCollection.orderBy('createdAt', descending: true).get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return RouteModel(
        id: doc.id,
        name: data['name'] as String,
        waypoints: (data['waypoints'] as List).map((point) {
          if (point is GeoPoint) {
            // Если это GeoPoint
            return LatLng(point.latitude, point.longitude);
          } else {
            throw Exception('Invalid waypoint type: $point');
          }
        }).toList(),
        createdAt: data['createdAt'] as Timestamp,
      );
    }).toList();
  }

  static Future<void> deleteRoute(String routeId) async {
    await _routesCollection.doc(routeId).delete();
  }
}
