import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/attraction.dart';

class AttractionsMap extends StatefulWidget {
  final MapController mapController;
  final double mapLat;
  final double mapLon;
  final double zoom;
  final List<Attraction> attractions;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const AttractionsMap({
    super.key,
    required this.mapController,
    required this.mapLat,
    required this.mapLon,
    required this.zoom,
    required this.attractions,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  _AttractionsMapState createState() => _AttractionsMapState();
}

class _AttractionsMapState extends State<AttractionsMap> {
  late MapController _mapController;
  late LatLng _currentCenter;
  late double _currentZoom;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController;

    _currentCenter = LatLng(widget.mapLat, widget.mapLon);
    _currentZoom = widget.zoom;
    widget.mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd && mounted) {
        setState(() {
          _currentCenter = _mapController.camera.center;
          _currentZoom = _mapController.camera.zoom;
        });
      }
    });

    // _mapController.mapEventStream.listen((event) {
    //   if (event is MapEventMoveEnd && mounted && !_isDisposed) {
    //     debugPrint(
    //         '[AttractionsMap] MapEventMoveEnd: new center ${_mapController.camera.center}, zoom ${_mapController.camera.zoom}');
    //     setState(() {
    //       _currentCenter = _mapController.camera.center;
    //       _currentZoom = _mapController.camera.zoom;
    //     });
    //   }
    // });
  }

  // @override
  // void dispose() {
  //   _isDisposed = true;
  //   _mapController.dispose();
  //   print('🛑 Карта удалена');
  //   super.dispose();
  // }

  void moveMap(LatLng newCenter, double newZoom) {
    if (mounted) {
      debugPrint(
          '[AttractionsMap] moveMap -> newCenter: $newCenter, newZoom: $newZoom');
      widget.mapController.move(newCenter, newZoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentCenter,
            initialZoom: _currentZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: widget.attractions.map((attr) {
                return Marker(
                  width: 40,
                  height: 40,
                  point: LatLng(attr.lat, attr.lon),
                  child: GestureDetector(
                    onTap: () => _showAttractionDialog(context, attr),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: "zoom_in",
                mini: true,
                onPressed: () {
                  if (!_isDisposed) {
                    setState(() {
                      _currentZoom += 1;
                      _mapController.move(_currentCenter, _currentZoom);
                    });
                  }
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: "zoom_out",
                mini: true,
                onPressed: () {
                  if (!_isDisposed) {
                    setState(() {
                      _currentZoom -= 1;
                      _mapController.move(_currentCenter, _currentZoom);
                    });
                  }
                },
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        )
      ],
    );
  }

  void _showAttractionDialog(BuildContext context, Attraction attr) {
    if (_isDisposed) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(attr.name),
        content: Text(attr.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
