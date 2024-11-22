import 'package:flutter/material.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/input_label.dart';

class HourlyPriceInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isPublic;
  final ValueChanged<bool?> onChanged;

  const HourlyPriceInput({
    Key? key,
    required this.controller,
    required this.isPublic,
    required this.onChanged,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InputLabel("Hourly Price"),
                Row(
                  children: [
                    Text("Public"),
                    Checkbox(
                      value: isPublic,
                      onChanged: onChanged,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            if (!isPublic)
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  hintText: "Enter hourly price",
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
                keyboardType: TextInputType.number,
              ),
            if (isPublic)
              TextFormField(
                controller: controller,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  hintText: "Free",
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