import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelerapp/features/favorities/data/models/favorite_place.dart';

part 'favorities_event.dart';
part 'favorities_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FirebaseFirestore firestore;
  final String userId;

  FavoritesBloc({required this.firestore, required this.userId})
      : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<AddFavoriteEvent>(_onAddFavorite);
    on<RemoveFavoriteEvent>(_onRemoveFavorite);
    on<FavoritesUpdatedEvent>((event, emit) {
      emit(FavoritesLoaded(event.favorites));
    });
  }

  Future<void> _onLoadFavorites(
      LoadFavoritesEvent event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    try {
      final snapshot = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      final favorites = snapshot.docs.map((doc) {
        return FavoritePlace.fromFirestore(doc.id, doc.data());
      }).toList();

      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError('Ошибка загрузки избранного: $e'));
    }
  }

  Future<void> _onAddFavorite(
      AddFavoriteEvent event, Emitter<FavoritesState> emit) async {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;

      // Проверка на дублирование
      if (currentState.favorites.any((place) => place.id == event.place.id)) {
        emit(FavoritesError('Место уже в избранном'));
        return;
      }

      final updatedFavorites = List<FavoritePlace>.from(currentState.favorites)
        ..add(event.place);

      emit(FavoritesLoaded(updatedFavorites));

      try {
        await firestore.collection('favorites').add(event.place.toMap());
      } catch (e) {
        emit(FavoritesError('Ошибка добавления места: $e'));
      }
    }
  }

  Future<void> _onRemoveFavorite(
      RemoveFavoriteEvent event, Emitter<FavoritesState> emit) async {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;

      final updatedFavorites = currentState.favorites
          .where((place) => place.id != event.id)
          .toList();

      emit(FavoritesLoaded(updatedFavorites));

      try {
        await firestore.collection('favorites').doc(event.id).delete();
      } catch (e) {
        emit(FavoritesError('Ошибка удаления места: $e'));
      }
    }
  }
}
