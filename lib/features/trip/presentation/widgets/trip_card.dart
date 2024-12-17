import 'package:flutter/material.dart';
import 'package:travelerapp/features/trip/data/models/trip_model.dart';
import 'package:travelerapp/features/trip/presentation/screens/trip_details_screen.dart';

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(trip.title),
        subtitle: Text(trip.description),
        leading: Image.network(trip.imageUrl, fit: BoxFit.cover, width: 50),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailsScreen(trip: trip),
            ),
          );
        },
      ),
    );
  }
}
