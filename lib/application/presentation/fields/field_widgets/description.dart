import 'package:flutter/material.dart';
import 'input_label.dart';
import 'text_field.dart';

class Description extends StatelessWidget {
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
            InputLabel("Description"),
            SizedBox(height: 10),
            CustomTextField(hint: "Enter a description", isMultiline: true),
          ],
        ),
      ),
    );
  }
}