import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservationCard extends StatelessWidget {
  final String creatorId;
  final List<String> joinedIds;
  final String reservationDate;
  final String reservationTime;
  final int slotsAvailable;
  final int maxSlots;

  const ReservationCard({
    Key? key,
    required this.creatorId,
    required this.joinedIds,
    required this.reservationDate,
    required this.reservationTime,
    required this.slotsAvailable,
    required this.maxSlots,
  }) : super(key: key);

  Future<Map<String, dynamic>> _fetchCreatorDetails() async {
    final response = await http.get(Uri.parse('http://localhost:3000/users/$creatorId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load creator details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchCreatorDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading creator details'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Creator details not found'));
        } else {
          final creatorDetails = snapshot.data!;
          final creatorName = '${creatorDetails['firstName']} ${creatorDetails['lastName']}';
          final creatorGender = creatorDetails['gender'];
          final creatorAge = _calculateAge(creatorDetails['birthDate']);
          final creatorImagePath = creatorDetails['imagePath'];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(creatorImagePath),
                    radius: 30,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          creatorName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Gender: $creatorGender',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        Text(
                          'Age: $creatorAge',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Reservation Date: $reservationDate',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        Text(
                          'Reservation Time: $reservationTime',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Slots: ${maxSlots - slotsAvailable}/$maxSlots',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: slotsAvailable < maxSlots ? Colors.green : Colors.red,
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
      },
    );
  }

  int _calculateAge(String birthDate) {
    if (birthDate.isEmpty) return 0;
    final parts = birthDate.split('/');
    if (parts.length != 3) return 0;
    final day = int.tryParse(parts[0]) ?? 1;
    final month = int.tryParse(parts[1]) ?? 1;
    final year = int.tryParse(parts[2]) ?? 2000;
    final birth = DateTime(year, month, day);
    final today = DateTime.now();
    int age = today.year - birth.year;
    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      age--;
    }
    return age;
  }
}