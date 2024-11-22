import 'package:flutter/material.dart';
import 'package:sport_meet/application/presentation/widgets/field_card.dart';
import 'package:sport_meet/application/presentation/fields/field_page.dart';

class FieldList extends StatelessWidget {
  final List<dynamic> filteredFieldData;

  const FieldList({required this.filteredFieldData, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredFieldData.length,
      itemBuilder: (context, index) {
        final field = filteredFieldData[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) {
      print('Navigating to FieldPage with data: $field');
      return FieldPage(
        fieldId: field['fieldId'] ?? '',
        fieldName: field['name'] ?? '',
        location: field['location'] ?? '',
        imagePath: field['images'] != null && field['images'].isNotEmpty ? field['images'][0] : '',
        schedule: field['schedule'] ?? {},
        contactEmail: field['contact'] != null ? field['contact']['email'] ?? '' : '',
        contactPhone: field['contact'] != null ? field['contact']['phone'] ?? '' : '',
        pricing: field['isPublic'] == true ? 'Free' : field['pricing'] ?? '', 
        sport: field['sport'] ?? '',
      );
    },
  ),
);
          },
          child: FieldCard(
            sport: field['sport'] ?? '',
            name: field['name'] ?? '',
            location: field['location'] ?? '',
            schedule: field['schedule'] ?? {},
            isPublic: field['isPublic'] ?? false,
            imagePath: field['images']?.first ?? '',
          ),
        );
      },
    );
  }
}
