import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:travelerapp/core/themes/app_theme.dart';
import 'package:travelerapp/features/attractions/bloc/bloc/attractions_bloc.dart';
import 'package:travelerapp/features/attractions/data/attractions_repository.dart';
import 'package:travelerapp/features/attractions/presentation/screens/attractions_page.dart';
import 'package:travelerapp/features/authentication/bloc/bloc/auth_bloc.dart';
import 'package:travelerapp/features/authentication/presentation/screens/login_screen.dart';
import 'package:travelerapp/features/authentication/presentation/screens/register_screen.dart';
import 'package:travelerapp/features/favorites/bloc/bloc/favorites_bloc.dart';
import 'package:travelerapp/features/favorites/presentation/screens/favorites_page.dart';
import 'package:travelerapp/features/home/presentation/screens/home_page.dart';
import 'package:travelerapp/features/profile/presentation/screens/profile_screen.dart';
import 'package:travelerapp/features/restaurants/screens/restaurant.dart';
import 'package:travelerapp/features/routes/presentation/screens/routes_page.dart';
import 'package:travelerapp/features/settings/presentation/screens/settings_page.dart';
import 'package:travelerapp/features/sleep/presentation/screens/hotels.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('settings');

  // Проверяем геолокацию перед запуском
  await _checkLocationPermission();

  // Получаем текущего пользователя
  final user = FirebaseAuth.instance.currentUser;
  final userId = user?.uid ??
      'guest'; // Если пользователя не аутентифицирован, используем 'guest'

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(settingsBox: Hive.box('settings')),
      child: TravelerApp(userId: userId),
    ),
  );
}

Future<void> _checkLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Проверяем, включена ли служба геолокации
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    debugPrint('Службы геолокации отключены. Используется Москва.');
    return;
  }

  // Проверяем разрешения
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('Доступ к геолокации отклонен. Используется Москва.');
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    debugPrint('Доступ к геолокации отклонен навсегда. Используется Москва.');
    return;
  }

  debugPrint('Геолокация разрешена');
}

class TravelerApp extends StatelessWidget {
  final String userId;

  const TravelerApp({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            firebaseAuth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
          ),
        ),
        BlocProvider(
          create: (context) => FavoritesBloc(
            firestore: FirebaseFirestore.instance,
            userId: userId,
          )..add(LoadFavorites()),
        ),
        BlocProvider(
          create: (context) =>
              AttractionsBloc(repository: AttractionsRepository()),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: themeProvider.currentTheme,
            initialRoute: '/',
            routes: {
              '/': (context) => HomePage(userId: userId),
              '/login': (context) => LoginScreen(),
              '/register': (context) => RegistrationScreen(),
              '/profile': (context) {
                final userId =
                    ModalRoute.of(context)?.settings.arguments as String?;
                if (userId == null) {
                  return const Scaffold(
                    body: Center(
                      child: Text(
                        'User ID is missing.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                return ProfileScreen(userId: userId);
              },
              '/settings': (context) => const SettingsPage(),
              '/favorites': (context) => const FavoritesPage(
                    userId: '',
                  ),
              '/routes': (context) => const RoutesPage(),
              '/hotels': (context) => TravelServicesPage(),
              '/restaurants': (context) => const RestaurantsMapPage(),
              '/attractions': (context) => AttractionsPage(),
            },
          );
        },
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  late bool _isDarkTheme;

  final Box settingsBox;

  ThemeProvider({required this.settingsBox})
      : _isDarkTheme = settingsBox.get('isDarkTheme', defaultValue: false);

  bool get isDarkTheme => _isDarkTheme;

  ThemeData get currentTheme {
    final theme = _isDarkTheme ? AppTheme.darkTheme : AppTheme.lightTheme;
    return theme;
  }

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    settingsBox.put('isDarkTheme', _isDarkTheme);
    notifyListeners();
  }
}
