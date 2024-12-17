import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelerapp/features/trip/bloc/bloc/trip_bloc.dart';
import 'package:travelerapp/features/trip/presentation/widgets/trip_card.dart';

class TripListScreen extends StatelessWidget {
  const TripListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      body: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          if (state is TripLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TripLoaded) {
            return ListView.builder(
              itemCount: state.trips.length,
              itemBuilder: (context, index) {
                final trip = state.trips[index];
                return TripCard(trip: trip);
              },
            );
          } else if (state is TripError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No trips available.'));
        },
      ),
    );
  }
}
