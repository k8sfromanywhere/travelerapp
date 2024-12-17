import 'package:flutter/material.dart';

class TripFilters extends StatelessWidget {
  final ValueChanged<String> onFilterSelected;

  const TripFilters({super.key, required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      items: const [
        DropdownMenuItem(value: 'All', child: Text('All')),
        DropdownMenuItem(value: 'City', child: Text('City')),
        DropdownMenuItem(value: 'Nature', child: Text('Nature')),
      ],
      onChanged: (value) {
        if (value != null) {
          onFilterSelected(value);
        }
      },
      hint: const Text('Select a category'),
    );
  }
}
