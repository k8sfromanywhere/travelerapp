part of 'trip_bloc.dart';

abstract class TripState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripLoaded extends TripState {
  final List<Trip> trips;

  TripLoaded({required this.trips});

  @override
  List<Object?> get props => [trips];
}

class TripError extends TripState {
  final String message;

  TripError({required this.message});

  @override
  List<Object?> get props => [message];
}
