import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class FilterDialog extends StatelessWidget {
  final List<String> sportsOptions;
  final List<String> availabilityOptions;
  final List<String> municipalities;
  final List<String> genderOptions;
  final List<String> selectedSports;
  final List<String> selectedAvailability;
  final List<String> selectedMunicipality;
  final String selectedGender;
  final Function(List<String>) onSportsChanged;
  final Function(List<String>) onAvailabilityChanged;
  final Function(List<String>) onMunicipalityChanged;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onApplyFilters;

  const FilterDialog({
    required this.sportsOptions,
    required this.availabilityOptions,
    required this.municipalities,
    required this.genderOptions,
    required this.selectedSports,
    required this.selectedAvailability,
    required this.selectedMunicipality,
    required this.selectedGender,
    required this.onSportsChanged,
    required this.onAvailabilityChanged,
    required this.onMunicipalityChanged,
    required this.onGenderChanged,
    required this.onClearFilters,
    required this.onApplyFilters,
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
            MultiSelectDialogField<String>(
              items: sportsOptions
                  .map((sport) => MultiSelectItem(sport, sport))
                  .toList(),
              initialValue: selectedSports,
              listType: MultiSelectListType.LIST,
              title: const Text(
                "Favorite Sports",
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
                "Favorite Sports",
                style: TextStyle(color: Colors.black),
              ),
              onConfirm: onSportsChanged,
              chipDisplay: MultiSelectChipDisplay(
                chipColor: const Color.fromARGB(255, 193, 50, 74),
                textStyle: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 16.0),
            MultiSelectDialogField<String>(
              items: availabilityOptions
                  .map((availability) =>
                      MultiSelectItem(availability, availability))
                  .toList(),
              initialValue: selectedAvailability,
              title: const Text(
                "Availability",
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
                "Availability",
                style: TextStyle(color: Colors.black),
              ),
              onConfirm: onAvailabilityChanged,
              chipDisplay: MultiSelectChipDisplay(
                chipColor: const Color.fromARGB(255, 193, 50, 74),
                textStyle: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 16.0),
            MultiSelectDialogField<String>(
              items: municipalities
                  .map((municipality) =>
                      MultiSelectItem(municipality, municipality))
                  .toList(),
              initialValue: selectedMunicipality,
              title: const Text(
                "Municipality",
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
                "Municipality",
                style: TextStyle(color: Colors.black),
              ),
              onConfirm: onMunicipalityChanged,
              chipDisplay: MultiSelectChipDisplay(
                chipColor: const Color.fromARGB(255, 193, 50, 74),
                textStyle: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedGender.isEmpty ? null : selectedGender,
              hint: const Text(
                'Gender',
                style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              items: genderOptions
                  .map((gender) =>
                      DropdownMenuItem(value: gender, child: Text(gender)))
                  .toList(),
              onChanged: onGenderChanged,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
              style: const TextStyle(color: Colors.black),
              dropdownColor: const Color.fromARGB(255, 118, 120, 120),
              iconEnabledColor: Colors.black,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClearFilters,
          child: const Text('Clear Filters'),
        ),
        TextButton(
          onPressed: onApplyFilters,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}