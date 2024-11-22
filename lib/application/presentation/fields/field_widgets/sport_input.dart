import 'package:flutter/material.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/input_label.dart';

class SportInput extends StatelessWidget {
  final TextEditingController controller;
  final List<String> sportsOptions;

  const SportInput({Key? key, required this.controller, required this.sportsOptions}) : super(key: key);

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
            InputLabel("Sport"),
            SizedBox(height: 10),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return sportsOptions;
                }
                return sportsOptions.where((String option) {
                  return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                controller.text = selection;
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted) {
                return TextFormField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    hintText: "Select or type a sport",
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}