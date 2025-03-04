import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/attractions_repository.dart';
import 'attractions_event.dart';
import 'attractions_state.dart';

class AttractionsBloc extends Bloc<AttractionsEvent, AttractionsState> {
  final AttractionsRepository repository;

  AttractionsBloc({required this.repository})
      : super(AttractionsState.initial()) {
    on<SearchCity>(_onSearchCity);
    on<LoadAttractions>(_onLoadAttractions);
    on<SearchCitySuggestions>(_onSearchCitySuggestions);
  }

  Future<void> _onSearchCity(
      SearchCity event, Emitter<AttractionsState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, error: ''));

      final coords = await repository.fetchCoordinates(event.city);
      if (coords == null) {
        emit(state.copyWith(isLoading: false, error: 'Город не найден'));
        return;
      }

      debugPrint(
          'Обновляем центр карты: lat: ${coords.latitude}, lon: ${coords.longitude}');

      emit(state.copyWith(
        isLoading: false,
        mapLat: coords.latitude,
        mapLon: coords.longitude,
        suggestions: [],
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadAttractions(
    LoadAttractions event,
    Emitter<AttractionsState> emit,
  ) async {
    try {
      debugPrint('[_onLoadAttractions] Начало — emit(isLoading: true)');
      emit(state.copyWith(isLoading: true, error: ''));

      debugPrint(
          '[_onLoadAttractions] Repository запрос (lat: ${event.lat}, lon: ${event.lon}, filter: ${event.filter})');
      final list = await repository.loadAttractions(
        lat: event.lat,
        lon: event.lon,
        filter: event.filter,
      );

      debugPrint('[_onLoadAttractions] Получено аттракций: ${list.length}');

      if (isClosed) {
        debugPrint('[_onLoadAttractions] BLoC уже закрыт, выходим');
        return;
      }

      debugPrint(
          '[_onLoadAttractions] emit(isLoading: false, обновляем attractions)');
      emit(state.copyWith(
        isLoading: false,
        attractions: list.isNotEmpty ? list : [],
      ));

      debugPrint('[_onLoadAttractions] Успешно обновили состояние');
    } catch (e, st) {
      debugPrint('[_onLoadAttractions] Ошибка: $e\nСтек: $st');

      if (isClosed) {
        debugPrint('[_onLoadAttractions] BLoC закрыт при ошибке, выходим');
        return;
      }

      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
        attractions: [],
      ));
    } finally {
      if (!isClosed && state.isLoading) {
        debugPrint('[_onLoadAttractions] finally — сбрасываем isLoading');
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  Future<void> _onSearchCitySuggestions(
    SearchCitySuggestions event,
    Emitter<AttractionsState> emit,
  ) async {
    debugPrint('Запрос подсказок для: ${event.query}');
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(suggestions: []));
      return;
    }
    try {
      final suggestionList = await repository.fetchCitySuggestions(event.query);
      debugPrint(
          'Получены подсказки: $suggestionList'); // Лог полученных данных

      emit(state.copyWith(error: '', suggestions: suggestionList));
    } catch (e) {
      debugPrint('Ошибка при получении подсказок: $e');
      emit(state.copyWith(error: 'Ошибка: $e', suggestions: []));
    }
  }
}
