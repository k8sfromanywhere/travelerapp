import 'package:flutter/material.dart';

class AttractionsFilterDropdown extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const AttractionsFilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedFilter.isEmpty ? null : selectedFilter,
      hint: const Text('Выберите фильтр'),
      items: const [
        DropdownMenuItem(value: '', child: Text('Все')),
        DropdownMenuItem(value: 'tourism=museum', child: Text('Музеи')),
        DropdownMenuItem(
            value: 'tourism=attraction', child: Text('Популярные места')),
        DropdownMenuItem(value: 'historic=monument', child: Text('Памятники')),
      ],
      onChanged: (filter) {
        final result = filter ?? '';
        onFilterChanged(result);
      },
    );
  }
}
