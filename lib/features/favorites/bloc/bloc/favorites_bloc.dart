import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelerapp/features/attractions/models/attraction.dart';

// Сообщаем, что в этом файле будут файлы-части:
part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FirebaseFirestore firestore;
  final String userId;

  FavoritesBloc({required this.firestore, required this.userId})
      : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
  }

  // Пример загрузки избранного
  Future<void> _onLoadFavorites(
      LoadFavorites event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    try {
      final snapshot = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      final favs = snapshot.docs.map((doc) {
        final data = doc.data();
        return Attraction(
          id: doc.id, // если хочешь сохранить docId
          name: data['name'] ?? 'Без названия',
          description: data['description'] ?? '',
          lat: (data['lat'] as num).toDouble(),
          lon: (data['lon'] as num).toDouble(),
        );
      }).toList();

      emit(FavoritesLoaded(favs));
    } catch (e) {
      emit(FavoritesError('Ошибка загрузки избранного: $e'));
    }
  }

  // Пример добавления
  Future<void> _onAddToFavorites(
      AddToFavorites event, Emitter<FavoritesState> emit) async {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;

      // Локально обновляем список
      final updated = List<Attraction>.from(currentState.favorites)
        ..add(event.attraction);
      emit(FavoritesLoaded(updated));

      try {
        await firestore.collection('favorites').add({
          'name': event.attraction.name,
          'description': event.attraction.description,
          'lat': event.attraction.lat,
          'lon': event.attraction.lon,
          'userId': userId,
        });
      } catch (e) {
        emit(FavoritesError('Ошибка добавления в избранное: $e'));
      }
    }
  }

  // Пример удаления
  Future<void> _onRemoveFromFavorites(
      RemoveFromFavorites event, Emitter<FavoritesState> emit) async {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;

      // Удаляем локально
      final updated = currentState.favorites
          .where((attr) => attr.id != event.docId)
          .toList();

      emit(FavoritesLoaded(updated));

      try {
        await firestore.collection('favorites').doc(event.docId).delete();
      } catch (e) {
        emit(FavoritesError('Ошибка удаления из избранного: $e'));
      }
    }
  }
}
