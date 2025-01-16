import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:travelerapp/features/attractions/bloc/bloc/attractions_bloc.dart';
import 'package:travelerapp/features/attractions/bloc/bloc/attractions_event.dart';
import 'package:travelerapp/features/attractions/bloc/bloc/attractions_state.dart';
import 'package:travelerapp/features/attractions/data/attractions_repository.dart';

class AttractionsPage extends StatelessWidget {
  final repository = AttractionsRepository();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttractionsBloc(repository: repository),
      child: const _AttractionsView(),
    );
  }
}

class _AttractionsView extends StatefulWidget {
  const _AttractionsView({Key? key}) : super(key: key);

  @override
  _AttractionsViewState createState() => _AttractionsViewState();
}

class _AttractionsViewState extends State<_AttractionsView> {
  final TextEditingController _cityController = TextEditingController();
  String _selectedFilter = '';

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AttractionsBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Достопримечательности'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Введите город',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (city) {
                bloc.add(SearchCity(city: city));
              },
            ),
          ),
          DropdownButton<String>(
            value: _selectedFilter,
            hint: const Text('Выберите фильтр'),
            items: const [
              DropdownMenuItem(value: '', child: Text('Все')),
              DropdownMenuItem(value: 'tourism=museum', child: Text('Музеи')),
              DropdownMenuItem(
                  value: 'tourism=attraction', child: Text('Популярные места')),
              DropdownMenuItem(
                  value: 'historic=monument', child: Text('Памятники')),
            ],
            onChanged: (filter) {
              setState(() {
                _selectedFilter = filter ?? '';
              });
              bloc.add(LoadAttractions(
                lat: context.read<AttractionsState>().mapLat,
                lon: context.read<AttractionsState>().mapLon,
                filter: _selectedFilter,
              ));
            },
          ),
          Expanded(
            child: BlocBuilder<AttractionsBloc, AttractionsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error.isNotEmpty) {
                  return Center(child: Text('Ошибка: ${state.error}'));
                }
                print('Количество меток: ${state.attractions.length}');

                return FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(state.mapLat, state.mapLon),
                    initialZoom: 12.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: state.attractions.map((attraction) {
                        print('Добавляем маркер для: ${attraction.name}');
                        return Marker(
                          point: LatLng(attraction.lat, attraction.lon),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(attraction.name),
                                  content: Text(attraction.description),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Закрыть'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Icon(Icons.location_on,
                                color: Colors.red),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
