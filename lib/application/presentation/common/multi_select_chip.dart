import 'package:flutter/material.dart';

class MultiSelectChip extends StatefulWidget {
  final List<String> availableOptions;
  final List<String> selectedSports;
  final Function(List<String>) onSelectionChanged;

  const MultiSelectChip(
    this.availableOptions, {
    required this.selectedSports,
    required this.onSelectionChanged,
    Key? key,
  }) : super(key: key);

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: widget.availableOptions.map((option) {
        bool isSelected = widget.selectedSports.contains(option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (isSelected) {
                widget.selectedSports.remove(option);
              } else {
                widget.selectedSports.add(option);
              }
              widget.onSelectionChanged(widget.selectedSports);
            });
          },
          selectedColor: Colors.green,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        );
      }).toList(),
    );
  }
}
