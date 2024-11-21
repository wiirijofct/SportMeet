import 'package:flutter/material.dart';
import 'input_label.dart';
import 'text_field.dart';

class Contacts extends StatelessWidget {
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
            InputLabel("Contacts"),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: CustomTextField(hint: "Email")),
                SizedBox(width: 16),
                Expanded(child: CustomTextField(hint: "Phone Number")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}