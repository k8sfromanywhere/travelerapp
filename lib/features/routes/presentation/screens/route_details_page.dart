import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RouteDetailsPage extends StatefulWidget {
  final String name;
  final List<LatLng> waypoints;

  const RouteDetailsPage({
    super.key,
    required this.name,
    required this.waypoints,
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
      if (mounted) {
        _updateMap();
      }
    });
  }

  /// Обновление карты для показа маршрута
  void _updateMap() {
    if (widget.waypoints.isNotEmpty && mounted) {
      final bounds = _calculateBounds(widget.waypoints);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(16.0), // Добавляем отступы
        ),
      );
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

  /// Кнопки зума (без `heroTag`)
  FloatingActionButton _buildZoomButton({
    //required tag,
    required IconData icon,
    required bool isZoomIn,
  }) {
    return FloatingActionButton(
      heroTag: UniqueKey().toString(),
      mini: true, // Мини-версия FAB
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
        title: Text(widget.name), // `Hero` больше не используется
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.waypoints.isNotEmpty
                  ? widget.waypoints.first
                  : const LatLng(55.0, 37.0), // Центр по умолчанию
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
              if (widget.waypoints.isNotEmpty)
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
                  // tag: 'bt+',
                  icon: Icons.zoom_in,
                  isZoomIn: true,
                ),
                const SizedBox(height: 8.0),
                _buildZoomButton(
                  // tag: 'bt-',
                  icon: Icons.zoom_out,
                  isZoomIn: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
