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
            DropdownButtonFormField<String>(
              items: sportsFilters.map((sport) {
                return DropdownMenuItem<String>(
                  value: sport,
                  child: Text(sport),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedSports.clear();
                  selectedSports.add(value);
                }
              },
              value: selectedSports.isNotEmpty ? selectedSports.first : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Field Privacy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<bool?>(
              items: [
                DropdownMenuItem<bool?>(
                  value: true,
                  child: const Text('Public'),
                ),
                DropdownMenuItem<bool?>(
                  value: false,
                  child: const Text('Private'),
                ),
                DropdownMenuItem<bool?>(
                  value: null,
                  child: const Text('No Preference'),
                ),
              ],
              onChanged: onPublicFilterChanged,
              value: isPublicFilter,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
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