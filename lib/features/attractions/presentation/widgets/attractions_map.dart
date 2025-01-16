import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AttractionsMap extends StatelessWidget {
  final List<Map<String, dynamic>> attractions;
  final double zoomLevel;

  const AttractionsMap({
    Key? key,
    required this.attractions,
    required this.zoomLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final markers = attractions
        .where((attraction) =>
            attraction['lat'] != null && attraction['lon'] != null)
        .map((attraction) {
      return Marker(
        point: LatLng(
          double.tryParse(attraction['lat'].toString()) ?? 0.0,
          double.tryParse(attraction['lon'].toString()) ?? 0.0,
        ),
        child: const Icon(Icons.location_on, color: Colors.red),
      );
    }).toList();

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(55.7558, 37.6173),
        initialZoom: zoomLevel,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
