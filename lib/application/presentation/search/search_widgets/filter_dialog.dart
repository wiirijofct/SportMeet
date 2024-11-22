import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class FilterDialog extends StatelessWidget {
  final List<String> sportsFilters;
  final List<String> selectedSports;
  final bool? isPublicFilter;
  final TimeOfDay? selectedTime;
  final VoidCallback onApply;
  final VoidCallback onClear;
  final ValueChanged<bool?> onPublicFilterChanged;
  final ValueChanged<TimeOfDay?> onTimeChanged;

  FilterDialog({
    required this.sportsFilters,
    required this.selectedSports,
    required this.isPublicFilter,
    required this.selectedTime,
    required this.onApply,
    required this.onClear,
    required this.onPublicFilterChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Options'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text("Sports", style: TextStyle(fontSize: 18.0)),
            ...sportsFilters.map((sport) {
              return CheckboxListTile(
                title: Text(sport),
                value: selectedSports.contains(sport),
                onChanged: (bool? selected) {
                  if (selected == true) {
                    selectedSports.add(sport);
                  } else {
                    selectedSports.remove(sport);
                  }
                },
              );
            }).toList(),
            const Text(
              'Field Privacy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            RadioListTile<bool?>(
              title: const Text('Public'),
              value: true,
              groupValue: isPublicFilter,
              onChanged: onPublicFilterChanged,
            ),
            RadioListTile<bool?>(
              title: const Text('Private'),
              value: false,
              groupValue: isPublicFilter,
              onChanged: onPublicFilterChanged,
            ),
            RadioListTile<bool?>(
              title: const Text('No Preference'),
              value: null,
              groupValue: isPublicFilter,
              onChanged: onPublicFilterChanged,
            ),
            const Text(
              'Time Filter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(selectedTime != null
                    ? '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                    : 'No time selected'),
                IconButton(
                  icon: const Icon(Ionicons.time_outline),
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      onTimeChanged(pickedTime);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClear,
          child: const Text('Clear Filters'),
        ),
        TextButton(
          onPressed: onApply,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}