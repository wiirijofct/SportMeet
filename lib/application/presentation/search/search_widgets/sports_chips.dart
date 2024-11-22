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
    // Create a new list where selected sports are at the start
    List<String> orderedSportsFilters = [
      ...selectedSports,
      ...sportsFilters.where((sport) => !selectedSports.contains(sport)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: orderedSportsFilters.map((sport) {
          final isSelected = selectedSports.contains(sport);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(sport),
              selected: isSelected,
              onSelected: (selected) {
                onToggleSport(sport);
              },
              selectedColor: Colors.brown,
              backgroundColor: Colors.grey.shade200,
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