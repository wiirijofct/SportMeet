import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String address;
  final String field;
  final String availability;
  final String imagePath;
  final String? time;

  const EventCard({
    Key? key,
    required this.title,
    required this.date,
    required this.address,
    required this.field,
    required this.availability,
    required this.imagePath,
    this.time,
  }) : super(key: key);

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
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0, // Reduced font size
                        ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    date,
                    style: TextStyle(fontSize: 14.0), // Reduced font size
                  ),
                  if (time != null)
                    Text(
                      'Time: $time',
                      style: TextStyle(fontSize: 14.0), // Reduced font size
                    ),
                  Text(
                    address,
                    style: TextStyle(fontSize: 14.0), // Reduced font size
                  ),
                  Text(
                    field,
                    style: TextStyle(fontSize: 14.0), // Reduced font size
                  ),
                  Text(
                    availability,
                    style: TextStyle(
                      fontSize: 14.0, // Reduced font size
                      color: availability.contains('OPEN')
                          ? Colors.green
                          : Colors.red,
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
