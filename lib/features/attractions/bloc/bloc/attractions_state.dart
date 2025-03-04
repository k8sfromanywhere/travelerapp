import '../../models/attraction.dart';
import '../../models/city_suggestion.dart';

class AttractionsState {
  final bool isLoading;
  final String error;
  final double mapLat;
  final double mapLon;
  final double zoom; // Добавим поле зума
  final List<Attraction> attractions;
  final List<CitySuggestion> suggestions;

  const AttractionsState({
    required this.isLoading,
    required this.error,
    required this.mapLat,
    required this.mapLon,
    required this.zoom,
    required this.attractions,
    required this.suggestions,
  });

  factory AttractionsState.initial() {
    return const AttractionsState(
      isLoading: false,
      error: '',
      mapLat: 55.7558,
      mapLon: 37.6173,
      zoom: 12.0, // Начальный зум
      attractions: [],
      suggestions: [],
    );
  }

  AttractionsState copyWith({
    bool? isLoading,
    String? error,
    double? mapLat,
    double? mapLon,
    double? zoom,
    List<Attraction>? attractions,
    List<CitySuggestion>? suggestions,
  }) {
    return AttractionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      mapLat: mapLat ?? this.mapLat,
      mapLon: mapLon ?? this.mapLon,
      zoom: zoom ?? this.zoom,
      attractions: attractions ?? this.attractions,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}
