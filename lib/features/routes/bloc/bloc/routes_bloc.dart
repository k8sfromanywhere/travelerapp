import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:travelerapp/features/routes/data/firebase_service.dart';
import 'package:travelerapp/features/routes/data/route_model.dart';

part 'routes_event.dart';
part 'routes_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc() : super(RouteInitial()) {
    on<AddRoutePointEvent>(_onAddRoutePoint);
    on<RemoveRoutePointEvent>(_onRemoveRoutePoint);
    on<SaveRouteEvent>(_onSaveRoute);
    on<LoadRoutesEvent>(_onLoadRoutes);
    on<DeleteRouteEvent>(_onDeleteRoute);
  }

  void _onAddRoutePoint(AddRoutePointEvent event, Emitter<RouteState> emit) {
    if (state is RouteLoaded) {
      final currentState = state as RouteLoaded;
      final updatedPoints = List<LatLng>.from(currentState.routePoints)
        ..add(event.point);
      emit(RouteLoaded(updatedPoints));
    } else {
      emit(RouteLoaded([event.point]));
    }
  }

  void _onRemoveRoutePoint(
      RemoveRoutePointEvent event, Emitter<RouteState> emit) {
    if (state is RouteLoaded) {
      final currentState = state as RouteLoaded;
      final updatedPoints = List<LatLng>.from(currentState.routePoints)
        ..remove(event.point);
      emit(RouteLoaded(updatedPoints));
    }
  }

  void _onSaveRoute(SaveRouteEvent event, Emitter<RouteState> emit) async {
    try {
      final newRoute = RouteModel(
        id: '', // Firestore сам создаст ID
        name: event.name,
        waypoints: event.routePoints,
        createdAt: Timestamp.now(), // Используем Firestore Timestamp
      );

      // Исправленный вызов метода `saveRoute`
      await FirebaseService.saveRoute(newRoute.name, newRoute.waypoints);

      emit(RouteSaved());
    } catch (error) {
      emit(RouteError('Не удалось сохранить маршрут: $error'));
    }
  }

  void _onLoadRoutes(LoadRoutesEvent event, Emitter<RouteState> emit) async {
    emit(RouteLoading());
    try {
      final routes = await FirebaseService.loadRoutes();
      emit(RoutesLoaded(routes));
    } catch (error) {
      emit(RouteError('Не удалось загрузить маршруты: $error'));
    }
  }

  void _onDeleteRoute(DeleteRouteEvent event, Emitter<RouteState> emit) async {
    try {
      await FirebaseService.deleteRoute(event.routeId);
      if (state is RoutesLoaded) {
        final currentState = state as RoutesLoaded;
        final updatedRoutes = currentState.routes
            .where((route) => route.id != event.routeId)
            .toList();
        emit(RoutesLoaded(updatedRoutes));
      }
    } catch (error) {
      emit(RouteError('Не удалось удалить маршрут: $error'));
    }
  }
}
