part of 'routes_bloc.dart';

abstract class RouteEvent {}

class AddRoutePointEvent extends RouteEvent {
  final LatLng point;

  AddRoutePointEvent(this.point);
}

class RemoveRoutePointEvent extends RouteEvent {
  final LatLng point;

  RemoveRoutePointEvent(this.point);
}

class SaveRouteEvent extends RouteEvent {
  final String name;
  final List<LatLng> routePoints;

  SaveRouteEvent(this.name, this.routePoints);
}

class LoadRoutesEvent extends RouteEvent {}

class DeleteRouteEvent extends RouteEvent {
  final String routeId;

  DeleteRouteEvent(this.routeId);
}
