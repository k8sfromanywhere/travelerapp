import 'package:flutter/material.dart';

class TravelLink {
  final String title;
  final String description;
  final Uri url;
  final IconData icon;
  final Color iconColor;

  TravelLink({
    required this.title,
    required this.description,
    required this.url,
    required this.icon,
    required this.iconColor,
  });
}
