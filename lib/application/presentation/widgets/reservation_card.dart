import 'package:flutter/material.dart';

class ReservationCard extends StatelessWidget {
  final String creatorName;
  final String creatorGender;
  final int creatorAge;
  final String reservationDate;
  final String reservationTime;
  final int slotsAvailable;
  final int maxSlots;
  final String creatorImagePath;

  const ReservationCard({
    Key? key,
    required this.creatorName,
    required this.creatorGender,
    required this.creatorAge,
    required this.reservationDate,
    required this.reservationTime,
    required this.slotsAvailable,
    required this.maxSlots,
    required this.creatorImagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    style: TextStyle(fontSize: 14.0),
                  ),
                  Text(
                    'Age: $creatorAge',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Reservation Date: $reservationDate',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  Text(
                    'Reservation Time: $reservationTime',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Slots: $slotsAvailable/$maxSlots',
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
}
