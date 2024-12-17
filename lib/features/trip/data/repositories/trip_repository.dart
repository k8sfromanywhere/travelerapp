import 'package:travelerapp/features/trip/data/models/trip_model.dart';

class TripRepository {
  Future<List<Trip>> fetchTrips() async {
    // Здесь можно добавить логику получения данных из Firestore или API
    await Future.delayed(const Duration(seconds: 2)); // Симуляция задержки
    return [
      Trip(
        id: '1',
        title: 'Trip to Paris',
        description: 'Visit the Eiffel Tower and Louvre Museum',
        category: 'City',
        imageUrl: 'https://example.com/paris.jpg',
      ),
      Trip(
        id: '2',
        title: 'Safari in Kenya',
        description: 'Experience the wildlife in Masai Mara',
        category: 'Nature',
        imageUrl: 'https://example.com/kenya.jpg',
      ),
    ];
  }
}
