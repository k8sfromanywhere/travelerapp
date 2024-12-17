import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:travelerapp/features/favorities/bloc/bloc/favorities_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем userId из arguments
    final userId = ModalRoute.of(context)!.settings.arguments as String;

    return BlocProvider(
      create: (context) => FavoritesBloc(
        firestore: FirebaseFirestore.instance,
        userId: userId,
      )..add(LoadFavoritesEvent(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Избранное'),
        ),
        body: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return const Center(child: Text('Нет избранных мест.'));
              }
              return ListView.builder(
                itemCount: state.favorites.length,
                itemBuilder: (context, index) {
                  final place = state.favorites[index];
                  return ListTile(
                    title: Text(place.name),
                    subtitle: Text(place.type), // Показываем тип
                  );
                },
              );
            } else if (state is FavoritesError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text('Нет избранных мест.'));
            }
          },
        ),
      ),
    );
  }
}
