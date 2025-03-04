import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:travelerapp/features/routes/presentation/screens/route_details_page.dart';
import 'add_route_page.dart';

class RoutesPage extends StatelessWidget {
  const RoutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сохраненные маршруты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddRoutePage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('routes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Нет сохраненных маршрутов.'));
          }

          final routes = snapshot.data!.docs;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              final id = route.id;
              final data = route.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'Без имени';
              final waypoints = (data['waypoints'] as List)
                  .map((point) => LatLng(
                        (point as GeoPoint).latitude,
                        point.longitude,
                      ))
                  .toList();

              return ListTile(
                title: Text(name),
                subtitle: Text('Точек: ${waypoints.length}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Мини-карта маршрута
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: waypoints.isEmpty
                          ? const Center(
                              child: Text(
                                'Нет данных',
                                style: TextStyle(fontSize: 10),
                              ),
                            )
                          : FlutterMap(
                              options: MapOptions(
                                initialCenter: waypoints.isNotEmpty
                                    ? waypoints.first
                                    : const LatLng(55.0, 37.0),
                                initialZoom: 13.0,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.all,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                ),
                                if (waypoints.isNotEmpty)
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: waypoints,
                                        strokeWidth: 2.0,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                if (waypoints.isNotEmpty)
                                  MarkerLayer(
                                    markers: waypoints.map((point) {
                                      return Marker(
                                        point: point,
                                        width: 10.0,
                                        height: 10.0,
                                        child: const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 10.0,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                    ),
                    // Кнопка удаления маршрута
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('routes')
                            .doc(id)
                            .delete();
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteDetailsPage(
                        name: name,
                        waypoints: waypoints,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Вычисление границ (bounds) для маршрута
  // LatLngBounds _calculateBounds(List<LatLng> points) {
  //   if (points.isEmpty) {
  //     return LatLngBounds(
  //       const LatLng(55.0, 37.0),
  //       const LatLng(55.0, 37.0),
  //     );
  //   }

  //   final sw = LatLng(
  //     points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
  //     points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
  //   );

  //   final ne = LatLng(
  //     points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
  //     points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
  //   );

  //   return LatLngBounds(sw, ne);
  // }
}
