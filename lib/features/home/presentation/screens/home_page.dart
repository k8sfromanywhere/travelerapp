import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required String userId});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text(
          'Traveler App',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (user == null) // Если пользователь не авторизован
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text(
                'Войти',
                style: TextStyle(color: Colors.white),
              ),
            )
          else // Если пользователь авторизован
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: user.uid, // Передаем userId в профиль
                );
              },
              child: const Text(
                'Профиль',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      backgroundColor: Colors.green.shade100,
      body: Column(
        children: [
          // Карта
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 29, 79, 31),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Имитация карты
                  const Center(
                    child: Icon(
                      Icons.map,
                      size: 150,
                      color: Colors.white,
                    ),
                  ),
                  // Кнопки на карте
                  Positioned(
                    top: 20,
                    left: 20,
                    child: _mapButton(Icons.hotel, Colors.green.shade700),
                  ),
                  Positioned(
                    top: 100,
                    right: 30,
                    child: _mapButton(Icons.apartment, Colors.green.shade700),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 80,
                    child: _mapButton(Icons.place, Colors.green.shade700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Меню с кнопками
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _menuButton(
                    context,
                    title: 'Достопримечательности',
                    icon: Icons.content_paste_search_sharp,
                    route: '/attractions',
                  ),
                  _menuButton(
                    context,
                    title: 'Избранные места',
                    icon: Icons.favorite,
                    route: '/favorites',
                    arguments: user?.uid, // Передаем userId в избранное
                  ),
                  _menuButton(
                    context,
                    title: 'Настройки',
                    icon: Icons.settings,
                    route: '/settings',
                  ),
                  _menuButton(
                    context,
                    title: 'Сохраненные маршруты',
                    icon: Icons.directions,
                    route: '/routes',
                  ),
                  _menuButton(
                    context,
                    title: 'Где поспать',
                    icon: Icons.hotel,
                    route: '/hotels',
                  ),
                  _menuButton(
                    context,
                    title: 'Где поесть',
                    icon: Icons.restaurant,
                    route: '/restaurants',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
    Object? arguments, // Добавляем параметр для передачи аргументов
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route, arguments: arguments),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade300,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green.shade900),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapButton(IconData icon, Color color) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 30,
        color: Colors.white,
      ),
    );
  }
}
