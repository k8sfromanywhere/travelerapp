import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RestaurantsMapPage extends StatefulWidget {
  const RestaurantsMapPage({super.key});

  @override
  _RestaurantsMapPageState createState() => _RestaurantsMapPageState();
}

class _RestaurantsMapPageState extends State<RestaurantsMapPage> {
  final TextEditingController _cityController = TextEditingController();
  final MapController _mapController = MapController();
  List<Map<String, dynamic>> _restaurants = [];
  List<Marker> _markers = [];
  bool _isLoading = false;
  LatLng _mapCenter = const LatLng(55.7558, 37.6173); // Москва по умолчанию
  double _zoomLevel = 13.0;

  @override
  void initState() {
    super.initState();
    // Перенос работы с BuildContext в didChangeDependencies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  /// Инициализация геолокации
  Future<void> _initializeLocation() async {
    try {
      // Геолокация и начальная настройка карты
      _mapCenter = const LatLng(55.7558, 37.6173); // Москва по умолчанию
      if (mounted) {
        _mapController.move(_mapCenter, _zoomLevel);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка получения геолокации: $e')),
        );
      }
    }
  }

  /// Поиск координат города с использованием Nominatim
  Future<LatLng?> _getCityCoordinates(String city) async {
    final url =
        'https://nominatim.openstreetmap.org/search?q=$city&format=json&limit=1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat']);
          final lon = double.tryParse(data[0]['lon']);
          if (lat != null && lon != null) {
            return LatLng(lat, lon);
          }
        }
      }
    } catch (e) {
      _showSnackBar('Ошибка получения координат города: $e');
    }
    return null;
  }

  /// Загрузка ресторанов через Overpass API
  Future<void> _fetchRestaurants(LatLng coordinates) async {
    const radiusInMeters = 5000; // Радиус поиска - 5 км
    final url = 'https://overpass-api.de/api/interpreter?data=[out:json];'
        'node[amenity=restaurant](around:$radiusInMeters,${coordinates.latitude},${coordinates.longitude});'
        'out;';

    setState(() {
      _isLoading = true;
      _restaurants = [];
      _markers = [];
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final elements = data['elements'] as List;

        setState(() {
          _restaurants = elements
              .where((place) =>
                  place['tags'] != null && place['tags']['name'] != null)
              .map((place) {
            final tags = place['tags'];
            return {
              'name': tags['name'],
              'cuisine': tags['cuisine'] ?? 'Неизвестная кухня',
              'lat': place['lat'],
              'lon': place['lon'],
            };
          }).toList();

          // Создаем маркеры
          _markers = _restaurants.map((restaurant) {
            return Marker(
              point: LatLng(restaurant['lat'], restaurant['lon']),
              child: GestureDetector(
                onTap: () => _showRestaurantInfo(restaurant),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 30.0,
                ),
              ),
            );
          }).toList();
        });
      } else {
        _showSnackBar('Ошибка загрузки данных: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Ошибка запроса: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Основная функция поиска ресторанов
  Future<void> _searchRestaurants(String city) async {
    final coordinates = await _getCityCoordinates(city);
    if (coordinates != null) {
      await _fetchRestaurants(coordinates);
      _mapController.move(coordinates, _zoomLevel);
    } else {
      _showSnackBar('Не удалось найти координаты города.');
    }
  }

  /// Показать информацию о ресторане
  void _showRestaurantInfo(Map<String, dynamic> restaurant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(restaurant['name']),
        content: Text('Кухня: ${restaurant['cuisine']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  /// Показать SnackBar с ошибкой
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рестораны'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _cityController,
                    onSubmitted: (value) => _searchRestaurants(value),
                    decoration: const InputDecoration(
                      labelText: 'Введите город',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _mapCenter,
                      initialZoom: _zoomLevel,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      MarkerLayer(markers: _markers),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}