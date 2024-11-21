import 'package:flutter/material.dart';
import 'input_label.dart';
import 'text_field.dart';

class HourlyPrice extends StatelessWidget {
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
            InputLabel("Hourly Price"),
            SizedBox(height: 10),
            CustomTextField(hint: "Enter hourly price", isNumber: true),
          ],
        ),
      ),
    );
  }
}