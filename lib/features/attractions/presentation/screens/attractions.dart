import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelerapp/features/attractions/bloc/bloc/attractions_bloc.dart';
import 'package:travelerapp/features/attractions/bloc/bloc/attractions_event.dart';
import 'package:travelerapp/features/attractions/bloc/bloc/attractions_state.dart';
import 'package:travelerapp/features/attractions/data/attractions_repository.dart';
import 'package:travelerapp/features/attractions/presentation/widgets/attractions_filter.dart';
import 'package:travelerapp/features/attractions/presentation/widgets/attractions_map.dart';

class AttractionsPage extends StatelessWidget {
  final Map<String, String> types = {
    'Все': '',
    'Достопримечательности': 'tourism=attraction',
    'Музеи': 'tourism=museum',
    'Исторические памятники': 'historic=monument',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Достопримечательности')),
      body: BlocProvider(
        // Здесь создаем AttractionsBloc
        create: (context) =>
            AttractionsBloc(repository: AttractionsRepository())
              ..add(FetchAttractions(city: 'Москва', type: '')),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AttractionsFilter(
                types: types,
                selectedType: '',
                onTypeSelected: (type) {
                  // Обновляем данные через блок
                  context
                      .read<AttractionsBloc>()
                      .add(FetchAttractions(city: 'Москва', type: type ?? ''));
                },
              ),
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
                  return AttractionsMap(
                    attractions: state.attractions,
                    zoomLevel: 10.0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
