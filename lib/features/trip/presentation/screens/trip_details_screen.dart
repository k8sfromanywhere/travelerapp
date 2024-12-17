import 'package:flutter/material.dart';
import 'package:travelerapp/features/trip/data/models/trip_model.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(trip.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(trip.imageUrl, fit: BoxFit.cover),
            const SizedBox(height: 10),
            Text(
              trip.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(trip.description),
          ],
        ),
      ),
    );
  }
}
