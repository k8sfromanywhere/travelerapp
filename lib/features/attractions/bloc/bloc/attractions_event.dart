import 'package:equatable/equatable.dart';

abstract class AttractionsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAttractions extends AttractionsEvent {
  final String city;
  final String type;

  FetchAttractions({required this.city, required this.type});

  @override
  List<Object?> get props => [city, type];
}
