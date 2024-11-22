import 'package:flutter/material.dart';

class FieldCard extends StatelessWidget {
  final String sport;
  final String name;
  final String location;
  final Map<String, dynamic> schedule;
  final bool isPublic;
  final String imagePath;

  const FieldCard({
    Key? key,
    required this.sport,
    required this.name,
    required this.location,
    required this.schedule,
    required this.isPublic,
    required this.imagePath,
  }) : super(key: key);

  String getCurrentDaySchedule() {
    final now = DateTime.now();
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final currentDay = daysOfWeek[now.weekday - 1];

    if (schedule.containsKey(currentDay)) {
      final daySchedule = schedule[currentDay];
      if (daySchedule is Map<String, String>) {
        return '${daySchedule['Opens']} - ${daySchedule['Closes']}';
      } else if (daySchedule is bool && !daySchedule) {
        return 'Closed';
      }
    }
    return 'No schedule available';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sport,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Name: $name',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  Text(
                    'Location: $location',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  Text(
                    'Schedule: ${getCurrentDaySchedule()}',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  Text(
                    isPublic ? 'Public Field' : 'Private Field',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: isPublic ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}