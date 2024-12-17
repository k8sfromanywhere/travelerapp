import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:travelerapp/features/restaurants/model/restaurants_model.dart';

part 'restaurants_event.dart';
part 'restaurants_state.dart';

class RestaurantsBloc extends Bloc<RestaurantsEvent, RestaurantsState> {
  final FirebaseFirestore firestore;
  final String userId;

  RestaurantsBloc({required this.firestore, required this.userId})
      : super(RestaurantsInitial()) {
    on<LoadRestaurantsEvent>(_onLoadRestaurants);
    on<AddRestaurantEvent>(_onAddRestaurant);
    on<RemoveRestaurantEvent>(_onRemoveRestaurant);
  }

  Future<void> _onLoadRestaurants(
      LoadRestaurantsEvent event, Emitter<RestaurantsState> emit) async {
    emit(RestaurantsLoading());
    try {
      final snapshot = await firestore
          .collection('restaurants')
          .where('userId', isEqualTo: userId)
          .get();

      final restaurants = snapshot.docs.map((doc) {
        return Restaurant.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      emit(RestaurantsLoaded(restaurants));
    } catch (e) {
      emit(RestaurantsError('Ошибка загрузки ресторанов: $e'));
    }
  }

  Future<void> _onAddRestaurant(
      AddRestaurantEvent event, Emitter<RestaurantsState> emit) async {
    try {
      await firestore.collection('restaurants').doc(event.restaurant.id).set(
            event.restaurant.toMap(),
          );
      add(LoadRestaurantsEvent());
    } catch (e) {
      emit(RestaurantsError('Ошибка добавления ресторана: $e'));
    }
  }

  Future<void> _onRemoveRestaurant(
      RemoveRestaurantEvent event, Emitter<RestaurantsState> emit) async {
    try {
      await firestore.collection('restaurants').doc(event.id).delete();
      add(LoadRestaurantsEvent());
    } catch (e) {
      emit(RestaurantsError('Ошибка удаления ресторана: $e'));
    }
  }
}
