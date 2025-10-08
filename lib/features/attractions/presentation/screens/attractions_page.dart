import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:travelerapp/features/attractions/bloc/bloc/attractions_bloc.dart';
import 'package:travelerapp/features/attractions/bloc/bloc/attractions_event.dart';
import 'package:travelerapp/features/attractions/bloc/bloc/attractions_state.dart';
import 'package:travelerapp/features/attractions/data/attractions_repository.dart';
import 'package:travelerapp/features/attractions/presentation/widgets/attractions_filter_dropdown.dart';
import 'package:travelerapp/features/attractions/presentation/widgets/attractions_map.dart';
import 'package:travelerapp/features/attractions/presentation/widgets/attractions_search_bar.dart';

class AttractionsPage extends StatelessWidget {
  final AttractionsRepository repository = AttractionsRepository();

  AttractionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Оборачиваем в BlocProvider
    return BlocProvider(
      create: (_) => AttractionsBloc(repository: repository),
      child: const _AttractionsView(),
    );
  }
}

class _AttractionsView extends StatefulWidget {
  const _AttractionsView();

  @override
  State<_AttractionsView> createState() => _AttractionsViewState();
}

class _AttractionsViewState extends State<_AttractionsView> {
  final TextEditingController _cityController = TextEditingController();
  final MapController _mapController = MapController();
  Timer? _debounceTimer;
  String _selectedFilter = '';

  @override
  Widget build(BuildContext context) {
    final favoritesBloc = context.read<AttractionsBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Достопримечательности')),
      body: Column(
        children: [
          // Поле поиска
          AttractionsSearchBar(
            cityController: _cityController,
            debounceTimer: _debounceTimer,
            onDebounceChanged: (timer) => _debounceTimer = timer,
          ),

          // Фильтр
          AttractionsFilterDropdown(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() => _selectedFilter = filter);
              final st = favoritesBloc.state;
              favoritesBloc.add(
                LoadAttractions(lat: st.mapLat, lon: st.mapLon, filter: filter),
              );
            },
          ),

          // Карта + зум
          Expanded(
            child: BlocConsumer<AttractionsBloc, AttractionsState>(
              listener: (context, state) {
                debugPrint(
                    '[BlocConsumer] listener: isLoading=${state.isLoading}, error=${state.error}');
                final newCenter = LatLng(state.mapLat, state.mapLon);

                if (_mapController.camera.center != newCenter) {
                  debugPrint(
                      '[BlocConsumer] Перемещаем карту: $newCenter / zoom: ${state.zoom}');
                  _mapController.move(newCenter, state.zoom);
                }

                if (state.error.isNotEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.error)));
                }
              },
              builder: (context, state) {
                debugPrint(
                    '[BlocConsumer] builder: isLoading=${state.isLoading}, attractions=${state.attractions.length}');
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return AttractionsMap(
                  mapController: _mapController,
                  mapLat: state.mapLat,
                  mapLon: state.mapLon,
                  zoom: state.zoom,
                  attractions: state.attractions,
                  onZoomIn: () {
                    final newZoom = _mapController.camera.zoom + 1;
                    _mapController.move(_mapController.camera.center, newZoom);
                  },
                  onZoomOut: () {
                    final newZoom = _mapController.camera.zoom - 1;
                    _mapController.move(_mapController.camera.center, newZoom);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
