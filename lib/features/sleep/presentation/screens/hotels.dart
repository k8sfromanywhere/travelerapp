import 'package:flutter/material.dart';
import 'package:travelerapp/features/sleep/data/travel_link.dart';
import 'package:url_launcher/url_launcher.dart';

/// Модель данных для ссылки

class TravelServicesPage extends StatelessWidget {
  TravelServicesPage({super.key});

  /// Ссылки на сервисы
  final List<TravelLink> _links = [
    TravelLink(
      title: 'Booking.com',
      description: 'Бронируйте отели по всему миру с удобными условиями.',
      url: Uri.parse('https://www.booking.com/'),
      icon: Icons.hotel,
      iconColor: Colors.blue,
    ),
    TravelLink(
      title: 'Airbnb',
      description: 'Аренда жилья для путешествий — от квартир до вилл.',
      url: Uri.parse('https://www.airbnb.com/'),
      icon: Icons.house,
      iconColor: Colors.green,
    ),
    TravelLink(
      title: 'Couchsurfing',
      description: 'Найдите бесплатное жильё у местных жителей.',
      url: Uri.parse('https://www.couchsurfing.com/'),
      icon: Icons.people,
      iconColor: Colors.orange,
    ),
    TravelLink(
      title: 'Trivago',
      description: 'Сравнивайте цены на отели и находите лучшие предложения.',
      url: Uri.parse('https://www.trivago.com/'),
      icon: Icons.search,
      iconColor: Colors.red,
    ),
    TravelLink(
      title: 'Яндекс.Путешествия',
      description: 'Планируйте поездки, бронируйте отели и билеты.',
      url: Uri.parse('https://travel.yandex.ru/'),
      icon: Icons.flight_takeoff,
      iconColor: Colors.purple,
    ),
    TravelLink(
      title: 'Островок',
      description: 'Бронируйте отели и квартиры по выгодным ценам.',
      url: Uri.parse('https://www.ostrovok.ru/'),
      icon: Icons.location_city,
      iconColor: Colors.teal,
    ),
  ];

  /// Метод для открытия ссылки в браузере
  Future<void> _launchInBrowser(BuildContext context, Uri url) async {
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Не удалось открыть ссылку: $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  /// Создание виджета для ссылки
  Widget _buildLinkTile(BuildContext context, TravelLink link) {
    return ListTile(
      leading: Icon(
        link.icon,
        color: link.iconColor,
        size: 40.0,
      ),
      title: Text(
        link.title,
        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        link.description,
        style: const TextStyle(fontSize: 14.0),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18.0),
      onTap: () => _launchInBrowser(context, link.url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Где поспать'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _links.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) => _buildLinkTile(context, _links[index]),
      ),
    );
  }
}
