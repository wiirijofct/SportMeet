import 'package:flutter/material.dart';

class PersonCard extends StatelessWidget {
  final String title;
  final String address;
  final String availability;
  final String sports;
  final String imagePath;
  final String gender;

  const PersonCard({
    Key? key,
    required this.title,
    required this.address,
    required this.availability,
    required this.sports,
    required this.imagePath,
    required this.gender
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
                  Text(
                    address,
                    style: TextStyle(fontSize: 14.0), // Reduced font size
                  ),
                  Text(
                    availability,
                    style: TextStyle(fontSize: 14.0),
                  ),
                  Text(
                    sports,
                    style: TextStyle(fontSize: 14.0), // Reduced font size
                  ),
                  Text(
                    gender,
                    style: TextStyle(fontSize: 14.0), // Reduced font size
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
