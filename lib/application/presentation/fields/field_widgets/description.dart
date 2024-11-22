import 'package:flutter/material.dart';
import 'input_label.dart';

class Description extends StatelessWidget {
  final TextEditingController controller;

  const Description({Key? key, required this.controller}) : super(key: key);

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
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter a description",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}