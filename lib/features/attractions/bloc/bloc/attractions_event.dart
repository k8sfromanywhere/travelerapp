import 'package:equatable/equatable.dart';

abstract class AttractionsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAttractions extends AttractionsEvent {
  final double lat;
  final double lon;
  final String filter;

  LoadAttractions({required this.lat, required this.lon, required this.filter});

  @override
  List<Object?> get props => [lat, lon, filter];
}

class SearchCity extends AttractionsEvent {
  final String city;

  SearchCity({required this.city});

  @override
  List<Object?> get props => [city];
}
