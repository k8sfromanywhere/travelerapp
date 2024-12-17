import 'package:flutter/material.dart';

class ProfileForm extends StatelessWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onSave;

  const ProfileForm(
      {super.key, required this.initialData, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: initialData['name']);
    final TextEditingController emailController =
        TextEditingController(text: initialData['email']);

    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            final updatedData = {
              'name': nameController.text,
              'email': emailController.text,
            };
            onSave(updatedData);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
