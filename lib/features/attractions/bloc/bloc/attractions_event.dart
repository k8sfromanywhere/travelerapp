abstract class AttractionsEvent {}

class SearchCity extends AttractionsEvent {
  final String city;
  SearchCity({required this.city});
}

class LoadAttractions extends AttractionsEvent {
  final double lat;
  final double lon;
  final String filter;
  LoadAttractions({required this.lat, required this.lon, required this.filter});
}

class SearchCitySuggestions extends AttractionsEvent {
  final String query;
  SearchCitySuggestions({required this.query});
}
