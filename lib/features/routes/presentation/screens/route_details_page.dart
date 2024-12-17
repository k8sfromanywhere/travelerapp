import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RouteDetailsPage extends StatefulWidget {
  final String name;
  final List<LatLng> waypoints;
  final String tag;

  const RouteDetailsPage({
    super.key,
    required this.name,
    required this.waypoints,
    required this.tag,
  });

  @override
  _RouteDetailsPageState createState() => _RouteDetailsPageState();
}

class _RouteDetailsPageState extends State<RouteDetailsPage> {
  final MapController _mapController = MapController();
  double _zoomLevel = 13.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMap();
    });
  }

  /// Обновление карты для показа маршрута
  void _updateMap() {
    if (widget.waypoints.isNotEmpty) {
      final bounds = _calculateBounds(widget.waypoints);

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(16.0), // Добавляем отступы
        ),
      );
    } else {
      _mapController.move(LatLng(55.0, 37.0), _zoomLevel); // Центр по умолчанию
    }
  }

  /// Рассчитываем границы для всех точек маршрута
  LatLngBounds _calculateBounds(List<LatLng> points) {
    final sw = LatLng(
      points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
      points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
    );

    final ne = LatLng(
      points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
      points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
    );

    return LatLngBounds(sw, ne);
  }

  /// Кнопки зума
  FloatingActionButton _buildZoomButton({
    required IconData icon,
    required bool isZoomIn,
    required String tag,
  }) {
    return FloatingActionButton(
      heroTag: tag,
      mini: true,
      onPressed: () {
        setState(() {
          _zoomLevel += isZoomIn ? 1 : -1;
          _mapController.move(
            _mapController.camera.center,
            _zoomLevel,
          );
        });
      },
      child: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: widget.tag,
          child: Text(widget.name),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.waypoints.isNotEmpty
                  ? widget.waypoints.first
                  : LatLng(55.0, 37.0), // Центр по умолчанию
              initialZoom: _zoomLevel,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              if (widget.waypoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.waypoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: widget.waypoints.map((point) {
                  return Marker(
                    point: point,
                    width: 30.0,
                    height: 30.0,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 30.0,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Column(
              children: [
                _buildZoomButton(
                  icon: Icons.zoom_in,
                  isZoomIn: true,
                  tag: 'zoom-in',
                ),
                const SizedBox(height: 8.0),
                _buildZoomButton(
                  icon: Icons.zoom_out,
                  isZoomIn: false,
                  tag: 'zoom-out',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
