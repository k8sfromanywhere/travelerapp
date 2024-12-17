part of 'trip_bloc.dart';

abstract class TripEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTripsEvent extends TripEvent {}

class FilterTripsEvent extends TripEvent {
  final String category;

  FilterTripsEvent({required this.category});

  @override
  List<Object?> get props => [category];
}
