import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelerapp/features/attractions/data/attractions_repository.dart';

import 'attractions_event.dart';
import 'attractions_state.dart';

class AttractionsBloc extends Bloc<AttractionsEvent, AttractionsState> {
  final AttractionsRepository repository;

  AttractionsBloc({required this.repository})
      : super(AttractionsState.initial()) {
    on<FetchAttractions>(_onFetchAttractions);
  }

  Future<void> _onFetchAttractions(
    FetchAttractions event,
    Emitter<AttractionsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      final attractions = await repository.fetchAttractions(
        event.city,
        event.type,
      );
      emit(state.copyWith(isLoading: false, attractions: attractions));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
