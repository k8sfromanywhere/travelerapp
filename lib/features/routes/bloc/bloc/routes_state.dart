part of 'routes_bloc.dart';

abstract class RouteState {}

class RouteInitial extends RouteState {}

class RouteLoading extends RouteState {}

class RouteLoaded extends RouteState {
  final List<LatLng> routePoints;

  RouteLoaded(this.routePoints);
}

class RoutesLoaded extends RouteState {
  final List<RouteModel> routes;

  RoutesLoaded(this.routes);
}

class RouteSaved extends RouteState {}

class RouteError extends RouteState {
  final String message;

  RouteError(this.message);
}
