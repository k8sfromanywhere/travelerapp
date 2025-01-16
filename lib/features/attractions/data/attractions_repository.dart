import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travelerapp/features/attractions/data/model.dart';

class AttractionsRepository {
  // Метод для получения списка достопримечательностей
  Future<List<Attraction>> fetchAttractions({
    required double lat,
    required double lon,
    required String filter,
  }) async {
    final filterQuery = '';
    //filter.isNotEmpty ? '[$filter]' : ''; // Для проверки уберите фильтр
    final url =
        'https://overpass-api.de/api/interpreter?data=[out:json];node$filterQuery(around:10000,$lat,$lon);out;';
    print('Запрос к API: $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки достопримечательностей.');
    }

    final rawData = json.decode(utf8.decode(response.bodyBytes));
    print('Данные из API: ${rawData['elements']}'); // Отладочный лог
    final data = rawData['elements'] as List;

    return data.map((e) {
      print('Добавляем объект: ${e['tags']?['name']}');
      return Attraction.fromJson(e);
    }).toList();
  }

  // Метод для получения координат города
  Future<Map<String, double>> fetchCityCoordinates(String city) async {
    final url =
        'https://nominatim.openstreetmap.org/search?q=$city&format=json&limit=1';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки координат города.');
    }

    final List<dynamic> data = json.decode(response.body);
    if (data.isEmpty) {
      throw Exception('Город не найден.');
    }

    return {
      'lat': double.parse(data[0]['lat']),
      'lon': double.parse(data[0]['lon']),
    };
  }
}
