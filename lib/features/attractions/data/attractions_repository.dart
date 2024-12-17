import 'dart:convert';
import 'package:http/http.dart' as http;

class AttractionsRepository {
  Future<List> fetchAttractions(String city, String type) async {
    final url =
        'https://nominatim.openstreetmap.org/search?q=$city&format=json&limit=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки координат города.');
    }

    final data = json.decode(response.body);
    if (data.isEmpty) {
      throw Exception('Город не найден.');
    }

    final lat = data[0]['lat'];
    final lon = data[0]['lon'];

    final filter = type.isEmpty ? '' : '[$type]';
    final overpassUrl =
        'https://overpass-api.de/api/interpreter?data=[out:json];node$filter(around:10000,$lat,$lon);out;';
    final attractionsResponse = await http.get(Uri.parse(overpassUrl));
    if (attractionsResponse.statusCode != 200) {
      throw Exception('Ошибка загрузки данных из OSM.');
    }

    final attractionsData =
        json.decode(utf8.decode(attractionsResponse.bodyBytes))['elements'];
    return attractionsData
        .where((element) => element['tags']?['name'] != null)
        .map((element) {
      return {
        'name': element['tags']['name'],
        'lat': element['lat'],
        'lon': element['lon'],
        'type': element['tags']['tourism'] ?? element['tags']['historic'] ?? '',
      };
    }).toList();
  }
}
