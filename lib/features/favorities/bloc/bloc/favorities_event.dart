part of 'favorities_bloc.dart';

abstract class FavoritesEvent {}

class LoadFavoritesEvent extends FavoritesEvent {
  final String userId;
  LoadFavoritesEvent(this.userId);
}

class AddFavoriteEvent extends FavoritesEvent {
  final FavoritePlace place;

  AddFavoriteEvent(this.place);

  List<Object?> get props => [place];
}

class RemoveFavoriteEvent extends FavoritesEvent {
  final String id;
  final String userId;

  RemoveFavoriteEvent(this.id, this.userId);

  List<Object?> get props => [id, userId];
}

class FavoritesUpdatedEvent extends FavoritesEvent {
  final List<FavoritePlace> favorites;

  FavoritesUpdatedEvent(this.favorites);

  List<Object?> get props => [favorites];
}
