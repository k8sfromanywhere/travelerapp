import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelerapp/features/attractions/bloc/bloc/attractions_bloc.dart';
import 'package:travelerapp/features/attractions/bloc/bloc/attractions_event.dart';
import 'package:travelerapp/features/attractions/bloc/bloc/attractions_state.dart';

class AttractionsSearchBar extends StatefulWidget {
  final TextEditingController cityController;
  final Timer? debounceTimer;
  final Function(Timer?) onDebounceChanged;

  const AttractionsSearchBar({
    Key? key,
    required this.cityController,
    required this.debounceTimer,
    required this.onDebounceChanged,
  }) : super(key: key);

  @override
  _AttractionsSearchBarState createState() => _AttractionsSearchBarState();
}

class _AttractionsSearchBarState extends State<AttractionsSearchBar> {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AttractionsBloc>();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          TextField(
            controller: widget.cityController,
            decoration: const InputDecoration(
              labelText: 'Введите город',
              border: OutlineInputBorder(),
            ),
            onChanged: (text) {
              print('Введён текст: $text');
              widget.debounceTimer?.cancel();
              final timer = Timer(const Duration(milliseconds: 400), () {
                bloc.add(SearchCitySuggestions(query: text));
              });
              widget.onDebounceChanged(timer);
            },
            onSubmitted: (city) {
              bloc.add(SearchCity(city: city));
            },
          ),
          BlocBuilder<AttractionsBloc, AttractionsState>(
            buildWhen: (prev, curr) => prev.suggestions != curr.suggestions,
            builder: (_, state) {
              if (state.suggestions.isEmpty) return const SizedBox();
              return Container(
                height: 150,
                color: Colors.white,
                child: ListView.builder(
                  itemCount: state.suggestions.length,
                  itemBuilder: (ctx, i) {
                    final suggestion = state.suggestions[i];
                    return ListTile(
                      title: Text(suggestion.displayName),
                      onTap: () {
                        print('Выбрана подсказка: ${suggestion.displayName}');
                        widget.cityController.text = suggestion.displayName;
                        bloc.add(SearchCity(city: suggestion.displayName));
                        bloc.add(SearchCitySuggestions(
                            query: '')); // Очистка подсказок
                        FocusScope.of(context)
                            .unfocus(); // Закрываем клавиатуру
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
