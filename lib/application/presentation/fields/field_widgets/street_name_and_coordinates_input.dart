import 'package:flutter/material.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/input_label.dart';

class StreetNameAndCoordinatesInput extends StatelessWidget {
  final TextEditingController streetNameController;
  final TextEditingController coordinatesController;

  const StreetNameAndCoordinatesInput({
    Key? key,
    required this.streetNameController,
    required this.coordinatesController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InputLabel("Street Name"),
            SizedBox(height: 10),
            TextFormField(
              controller: streetNameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                hintText: "Enter the street name",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                ),
              ),
            ),
            SizedBox(height: 20),
            InputLabel("Coordinates"),
            SizedBox(height: 10),
            TextFormField(
              controller: coordinatesController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                hintText: "Enter the coordinates",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}