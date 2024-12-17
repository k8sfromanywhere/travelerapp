part of 'restaurants_bloc.dart';

abstract class RestaurantsEvent extends Equatable {
  const RestaurantsEvent();
}

class LoadRestaurantsEvent extends RestaurantsEvent {
  @override
  List<Object?> get props => [];
}

class AddRestaurantEvent extends RestaurantsEvent {
  final Restaurant restaurant;

  const AddRestaurantEvent(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}

class RemoveRestaurantEvent extends RestaurantsEvent {
  final String id;

  const RemoveRestaurantEvent(this.id);

  @override
  List<Object?> get props => [id];
}
