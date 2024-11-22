import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart';

class FilterDialog extends StatefulWidget {
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
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.selectedTime;
  }

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
            MultiSelectDialogField<String>(
              items: widget.sportsFilters
                  .map((sport) => MultiSelectItem(sport, sport))
                  .toList(),
              initialValue: widget.selectedSports,
              listType: MultiSelectListType.LIST,
              title: const Text(
                "Sports",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selectedColor: const Color.fromARGB(255, 193, 50, 74),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              buttonText: const Text(
                "Sports",
                style: TextStyle(color: Colors.black),
              ),
              onConfirm: (values) {
                widget.selectedSports.clear();
                widget.selectedSports.addAll(values);
              },
              chipDisplay: MultiSelectChipDisplay(
                chipColor: const Color.fromARGB(255, 193, 50, 74),
                textStyle: const TextStyle(color: Colors.black),
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
              onChanged: widget.onPublicFilterChanged,
              value: widget.isPublicFilter,
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
                Text(_selectedTime != null
                    ? DateFormat.jm().format(DateTime(0, 0, 0, _selectedTime!.hour, _selectedTime!.minute))
                    : 'No time selected'),
                IconButton(
                  icon: const Icon(Ionicons.time_outline),
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedTime = pickedTime;
                      });
                      widget.onTimeChanged(pickedTime);
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
          onPressed: widget.onClear,
          child: const Text('Clear Filters'),
        ),
        TextButton(
          onPressed: () {
            widget.onApply();
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}