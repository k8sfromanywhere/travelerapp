import 'package:flutter/material.dart';

class AttractionsFilter extends StatelessWidget {
  final Map<String, String> types;
  final String? selectedType; // Позволяет значению быть null
  final ValueChanged<String?> onTypeSelected;

  const AttractionsFilter({
    Key? key,
    required this.types,
    required this.selectedType,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: types.containsKey(selectedType) ? selectedType : null,
      hint: const Text('Выберите тип'),
      isExpanded: true,
      items: types.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.key),
        );
      }).toList(),
      onChanged: onTypeSelected,
    );
  }
}
