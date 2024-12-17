import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileInfo({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name: ${userData['name']}'),
        Text('Email: ${userData['email']}'),
      ],
    );
  }
}
