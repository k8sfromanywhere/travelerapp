import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:travelerapp/features/trip/data/models/trip_model.dart';
import 'package:travelerapp/features/trip/data/repositories/trip_repository.dart';

part 'trip_event.dart';
part 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository tripRepository;

  TripBloc({required this.tripRepository}) : super(TripInitial()) {
    on<LoadTripsEvent>(_onLoadTrips);
    on<FilterTripsEvent>(_onFilterTrips);
  }

  Future<void> _onLoadTrips(
      LoadTripsEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trips = await tripRepository.fetchTrips();
      emit(TripLoaded(trips: trips));
    } catch (e) {
      emit(TripError(message: e.toString()));
    }
  }

  void _onFilterTrips(FilterTripsEvent event, Emitter<TripState> emit) {
    if (state is TripLoaded) {
      final filteredTrips = (state as TripLoaded)
          .trips
          .where((trip) => trip.category == event.category)
          .toList();
      emit(TripLoaded(trips: filteredTrips));
    }
  }
}
