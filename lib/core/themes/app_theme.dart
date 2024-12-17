import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            const Color.fromARGB(255, 66, 107, 67),
          ),
        ),
      ),
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Colors.black,
        onPrimary: Colors.greenAccent,
        secondary: Colors.black,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: Color.fromRGBO(210, 210, 187, 1),
        onSurface: Color.fromARGB(255, 3, 15, 3),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            const Color.fromARGB(255, 50, 50, 50),
          ),
        ),
      ),
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Colors.white,
        onPrimary: Colors.black,
        secondary: Colors.grey,
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        surface: Color.fromRGBO(28, 28, 30, 1),
        onSurface: Colors.white,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  late bool _isDarkTheme;
  final Box settingsBox;

  ThemeProvider({required this.settingsBox}) {
    // Инициализация переменных с использованием значений из Hive
    _isDarkTheme = settingsBox.get('isDarkTheme', defaultValue: false);
  }

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
