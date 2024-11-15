import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sport_meet/application/presentation/widgets/reservation_card.dart';

class FieldPage extends StatelessWidget {
  final String fieldName;
  final String location;
  final String imagePath;
  final String schedule;
  final String contactEmail;
  final String contactPhone;
  final String pricing;
  final List<Map<String, String>> upcomingEvents;

  const FieldPage({
    Key? key,
    required this.fieldName,
    required this.location,
    required this.imagePath,
    required this.schedule,
    required this.contactEmail,
    required this.contactPhone,
    required this.pricing,
    required this.upcomingEvents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fieldName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Ionicons.location_outline),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFieldDetailRow(
                    icon: Ionicons.time_outline,
                    title: 'Schedule',
                    detail: schedule,
                  ),
                  const SizedBox(height: 8),
                  _buildFieldDetailRow(
                    icon: Ionicons.mail_outline,
                    title: 'Email',
                    detail: contactEmail,
                  ),
                  const SizedBox(height: 8),
                  _buildFieldDetailRow(
                    icon: Ionicons.call_outline,
                    title: 'Phone',
                    detail: contactPhone,
                  ),
                  const SizedBox(height: 8),
                  _buildFieldDetailRow(
                    icon: Ionicons.cash_outline,
                    title: 'Pricing per hour',
                    detail: pricing,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Upcoming Events',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: upcomingEvents.length,
                    itemBuilder: (context, index) {
                      final event = upcomingEvents[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ReservationCard(
                          creatorName: event['creatorName']!,
                          creatorGender: event['creatorGender']!,
                          creatorAge: int.parse(event['creatorAge']!),
                          reservationDate: event['reservationDate']!,
                          reservationTime: event['reservationTime']!,
                          slotsAvailable: int.parse(event['slotsAvailable']!),
                          maxSlots: int.parse(event['maxSlots']!),
                          creatorImagePath: event['creatorImagePath']!,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 70,
      centerTitle: true,
      backgroundColor: Colors.red,
      title: const Text(
        'FIELD DETAILS',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildFieldDetailRow({
    required IconData icon,
    required String title,
    required String detail,
  }) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$title: $detail',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
