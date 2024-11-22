import 'package:flutter/material.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/input_label.dart';

class FieldNameInput extends StatelessWidget {
  final TextEditingController controller;

  const FieldNameInput({Key? key, required this.controller}) : super(key: key);

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
            InputLabel("Field Name"),
            SizedBox(height: 10),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                hintText: "Enter the field name",
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