import 'package:flutter/material.dart';

class SportsChips extends StatelessWidget {
  final List<String> sportsFilters;
  final List<String> selectedSports;
  final ValueChanged<String> onToggleSport;

  const SportsChips({
    required this.sportsFilters,
    required this.selectedSports,
    required this.onToggleSport,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sportsFilters.map((sport) {
          final isSelected = selectedSports.contains(sport);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(sport),
              selected: isSelected,
              onSelected: (_) => onToggleSport(sport),
              selectedColor: Colors.brown,
              backgroundColor: Colors.grey.shade300,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
