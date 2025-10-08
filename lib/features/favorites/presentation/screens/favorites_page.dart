import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelerapp/features/favorites/bloc/bloc/favorites_bloc.dart';

class FavoritesPage extends StatelessWidget {
  final String userId;
  const FavoritesPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Берём уже созданный BLoC
    final favoritesBloc = context.read<FavoritesBloc>();
    // Если нужно перезагрузить заново:
    // favoritesBloc.add(LoadFavorites());

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoritesLoaded) {
            final favs = state.favorites;
            if (favs.isEmpty) {
              return const Center(child: Text('Нет избранных мест'));
            }
            return ListView.builder(
              itemCount: favs.length,
              itemBuilder: (context, index) {
                final item = favs[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Удаляем
                      // event.docId = item.id
                      favoritesBloc.add(RemoveFromFavorites(item.id));
                    },
                  ),
                );
              },
            );
          } else if (state is FavoritesError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
