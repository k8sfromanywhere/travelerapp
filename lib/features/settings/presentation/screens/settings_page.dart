import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelerapp/main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Смена темы
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Темная тема'),
            trailing: Switch(
              value: themeProvider.isDarkTheme,
              onChanged: (value) => themeProvider.toggleTheme(),
            ),
          ),
          const Divider(),

          // О приложении
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('О приложении'),
            subtitle: const Text('Версия: 1.0.0'),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  /// Диалог "О приложении"
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Travel App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.travel_explore),
      children: const [
        Text('Приложение для путешествий'),
        Text('Разработано с использованием Flutter и Hive.'),
      ],
    );
  }
}
