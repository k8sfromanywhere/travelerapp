import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class AddRoutePage extends StatefulWidget {
  const AddRoutePage({super.key});

  @override
  State<AddRoutePage> createState() => _AddRoutePageState();
}

class _AddRoutePageState extends State<AddRoutePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<LatLng> _waypoints = [];
  final MapController _mapController = MapController();
  LatLng _currentPosition =
      const LatLng(55.7558, 37.6173); // Москва по умолчанию
  double _zoomLevel = 13.0;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  /// Инициализация текущей позиции
  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Службы геолокации отключены. Используется Москва.',
            ),
          ),
        );
        _mapController.move(_currentPosition, _zoomLevel);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Разрешение на геолокацию отклонено. Используется Москва.',
              ),
            ),
          );
          _mapController.move(_currentPosition, _zoomLevel);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Разрешение на геолокацию заблокировано. Используется Москва.',
            ),
          ),
        );
        _mapController.move(_currentPosition, _zoomLevel);
        return;
      }

      // Получение текущей позиции
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      // Перемещение карты на текущую позицию
      _mapController.move(_currentPosition, _zoomLevel);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка получения геолокации: $e. Используется Москва.',
          ),
        ),
      );
      _mapController.move(_currentPosition, _zoomLevel);
    }
  }

  /// Выполнение поиска через Nominatim
  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;

    final url =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final results = json.decode(response.body) as List;
        setState(() {
          _searchResults = results
              .map((place) => {
                    'name': place['display_name'],
                    'lat': double.parse(place['lat']),
                    'lon': double.parse(place['lon']),
                  })
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка поиска: $e')),
      );
    }
  }

  /// Выбор места из поиска
  void _selectPlace(Map<String, dynamic> place) {
    final latLng = LatLng(place['lat'], place['lon']);
    setState(() {
      _mapController.move(latLng, _zoomLevel); // Перемещаем карту
      _waypoints.add(latLng); // Добавляем точку в маршрут
      _searchResults.clear(); // Очищаем результаты поиска
      _searchController.clear(); // Сбрасываем поле поиска
    });
  }

  /// Сохранение маршрута
  void _saveRoute() async {
    if (_nameController.text.isEmpty || _waypoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите имя маршрута и добавьте хотя бы одну точку!'),
        ),
      );
      return;
    }

    final routeData = {
      'name': _nameController.text,
      'waypoints': _waypoints
          .map((point) => GeoPoint(point.latitude, point.longitude))
          .toList(),
    };

    try {
      await FirebaseFirestore.instance.collection('routes').add(routeData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Маршрут успешно сохранен!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения маршрута: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить маршрут')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название маршрута',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Поиск места',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _searchPlace,
            ),
          ),
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final place = _searchResults[index];
                  return ListTile(
                    title: Text(place['name']),
                    onTap: () => _selectPlace(place),
                  );
                },
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition, // Начальная позиция
                    initialZoom: _zoomLevel,
                    onTap: (tapPosition, latLng) {
                      setState(() {
                        _waypoints.add(latLng);
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    if (_waypoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _waypoints,
                            strokeWidth: 4.0,
                            color: const Color.fromARGB(255, 6, 51, 87),
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: _waypoints.map((point) {
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
                  bottom: 16,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            _zoomLevel++;
                            _mapController.move(
                                _mapController.camera.center, _zoomLevel);
                          });
                        },
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            _zoomLevel--;
                            _mapController.move(
                                _mapController.camera.center, _zoomLevel);
                          });
                        },
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _saveRoute,
              child: const Text('Сохранить маршрут'),
            ),
          ),
        ],
      ),
    );
  }
}
