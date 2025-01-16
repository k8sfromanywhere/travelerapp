import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelerapp/features/attractions/data/attractions_repository.dart';
import 'attractions_event.dart';
import 'attractions_state.dart';

class AttractionsBloc extends Bloc<AttractionsEvent, AttractionsState> {
  final AttractionsRepository repository;

  AttractionsBloc({required this.repository})
      : super(AttractionsState.initial()) {
    on<LoadAttractions>(_onLoadAttractions);
    on<SearchCity>(_onSearchCity);
  }

  Future<void> _onLoadAttractions(
    LoadAttractions event,
    Emitter<AttractionsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      final attractions = await repository.fetchAttractions(
        lat: event.lat,
        lon: event.lon,
        filter: event.filter,
      );
      print('Количество достопримечательностей: ${attractions.length}');
      emit(state.copyWith(isLoading: false, attractions: attractions));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      print('Ошибка: ${e.toString()}');
    }
  }

  Future<void> _onSearchCity(
    SearchCity event,
    Emitter<AttractionsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      final coordinates = await repository.fetchCityCoordinates(event.city);
      emit(state.copyWith(
        isLoading: false,
        mapLat: coordinates['lat']!,
        mapLon: coordinates['lon']!,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
