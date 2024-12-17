import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AttractionsMap extends StatelessWidget {
  final List attractions;
  final double zoomLevel;

  const AttractionsMap({
    Key? key,
    required this.attractions,
    required this.zoomLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final markers = attractions.map((attraction) {
      return Marker(
        point: LatLng(attraction['lat'], attraction['lon']),
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
