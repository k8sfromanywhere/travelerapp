part of 'favorites_bloc.dart';

abstract class FavoritesEvent {}

class LoadFavorites extends FavoritesEvent {}

class AddToFavorites extends FavoritesEvent {
  final Attraction attraction;
  AddToFavorites({required this.attraction});
}

class RemoveFromFavorites extends FavoritesEvent {
  final String docId;
  RemoveFromFavorites(this.docId);
}
