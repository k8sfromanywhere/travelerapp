import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/attraction.dart';
import '../models/city_suggestion.dart';

class Coordinates {
  final double latitude;
  final double longitude;
  const Coordinates({required this.latitude, required this.longitude});
}

class AttractionsRepository {
  Future<Coordinates?> fetchCoordinates(String cityName) async {
    if (cityName.isEmpty) return null;

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$cityName&type=city&addressdetails=1&limit=5');

    debugPrint('Запрос координат для города: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          // Фильтруем, чтобы убрать районы и области
          final bestMatch = data.firstWhere(
            (item) => item['type'] == 'city' || item['type'] == 'town',
            orElse: () => data.first, // Если нет, берём первый
          );

          final lat = double.parse(bestMatch['lat']);
          final lon = double.parse(bestMatch['lon']);

          debugPrint(
              'Центр города: ${bestMatch['display_name']} -> lat: $lat, lon: $lon');

          return Coordinates(latitude: lat, longitude: lon);
        }
      }

      debugPrint('Город не найден: $cityName');
      return null;
    } catch (e) {
      debugPrint('Ошибка при получении координат: $e');
      return null;
    }
  }

  Future<List<CitySuggestion>> fetchCitySuggestions(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query&addressdetails=1&limit=5');

    debugPrint('Запрос к Nominatim API: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        debugPrint('Ответ от API: $data');

        return data.where((item) => item['address'] != null).map((item) {
          final address = item['address'];
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['municipality'] ??
              item['display_name']; // Если ничего нет, fallback на полное имя

          return CitySuggestion(
            displayName: city,
            lat: double.parse(item['lat']),
            lon: double.parse(item['lon']),
          );
        }).toList();
      } else {
        debugPrint('Ошибка API: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Ошибка при запросе подсказок: $e');
      return [];
    }
  }

  Future<List<Attraction>> loadAttractions({
    required double lat,
    required double lon,
    required String filter,
  }) async {
    final baseUrl = 'https://overpass-api.de/api/interpreter';

    final query = '''
  [out:json];
  node
    [${filter.isNotEmpty ? filter : 'tourism'}]
    (around:5000, $lat, $lon);
  out;
  ''';

    final url = Uri.parse('$baseUrl?data=${Uri.encodeComponent(query)}');

    debugPrint('Запрос достопримечательностей: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Декодируем JSON вручную, чтобы избежать проблем с кодировкой
        final decodedResponse = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedResponse);

        final attractions = (data['elements'] as List)
            .map((item) => Attraction(
                  name: utf8.decode(
                      utf8.encode(item['tags']['name'] ?? 'Неизвестное место')),
                  description: utf8.decode(utf8
                      .encode(item['tags']['description'] ?? 'Нет описания')),
                  lat: item['lat'],
                  lon: item['lon'],
                  id: '',
                ))
            .toList();

        debugPrint('Найдено достопримечательностей: ${attractions.length}');
        return attractions;
      }

      debugPrint(
          'Ошибка загрузки достопримечательностей: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Ошибка: $e');
      return [];
    }
  }

  // Сохранить в избранное
  Future<void> addToFavorites(Attraction attraction) async {
    await FirebaseFirestore.instance.collection('favorites').add({
      'name': attraction.name,
      'description': attraction.description,
      'lat': attraction.lat,
      'lon': attraction.lon,
    });
  }

  // Загрузить все избранные места
  Future<List<Attraction>> loadFavorites() async {
    final query =
        await FirebaseFirestore.instance.collection('favorites').get();
    return query.docs.map((doc) {
      final data = doc.data();
      return Attraction(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        lat: data['lat'] ?? 0.0,
        lon: data['lon'] ?? 0.0,
      );
    }).toList();
  }
}
