import 'package:equatable/equatable.dart';
import 'package:travelerapp/features/attractions/data/model.dart';

class AttractionsState extends Equatable {
  final bool isLoading;
  final List<Attraction> attractions;
  final String error;
  final double mapLat;
  final double mapLon;

  const AttractionsState({
    required this.isLoading,
    required this.attractions,
    required this.error,
    required this.mapLat,
    required this.mapLon,
  });

  factory AttractionsState.initial() {
    return const AttractionsState(
      isLoading: false,
      attractions: [],
      error: '',
      mapLat: 55.7558, // Москва по умолчанию
      mapLon: 37.6173,
    );
  }

  AttractionsState copyWith({
    bool? isLoading,
    List<Attraction>? attractions,
    String? error,
    double? mapLat,
    double? mapLon,
  }) {
    return AttractionsState(
      isLoading: isLoading ?? this.isLoading,
      attractions: attractions ?? this.attractions,
      error: error ?? this.error,
      mapLat: mapLat ?? this.mapLat,
      mapLon: mapLon ?? this.mapLon,
    );
  }

  @override
  List<Object?> get props => [isLoading, attractions, error, mapLat, mapLon];
}
