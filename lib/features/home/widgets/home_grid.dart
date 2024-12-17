import 'package:flutter/material.dart';

class HomeGrid extends StatelessWidget {
  const HomeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      const _Feature(
        icon: Icons.map,
        title: 'Карта',
        route: '/map',
      ),
      const _Feature(
        icon: Icons.favorite,
        title: 'Избранное',
        route: '/favorites',
      ),
      const _Feature(
        icon: Icons.settings,
        title: 'Настройки',
        route: '/settings',
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
      ),
      itemBuilder: (context, index) {
        final feature = features[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, feature.route);
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 4.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(feature.icon, size: 48, color: Colors.green),
                const SizedBox(height: 8.0),
                Text(
                  feature.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String route;

  const _Feature(
      {required this.icon, required this.title, required this.route});
}
