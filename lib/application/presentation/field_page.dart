import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sport_meet/application/presentation/widgets/reservation_card.dart';
import 'package:http/http.dart' as http;

class FieldPage extends StatelessWidget {
  final String fieldId;
  final String fieldName;
  final String location;
  final String imagePath;
  final String schedule;
  final String contactEmail;
  final String contactPhone;
  final String pricing;

  const FieldPage({
    Key? key,
    required this.fieldId,
    required this.fieldName,
    required this.location,
    required this.imagePath,
    required this.schedule,
    required this.contactEmail,
    required this.contactPhone,
    required this.pricing,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchReservations() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/reservations'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .where((reservation) => reservation['fieldId'].toString() == fieldId)
            .map<Map<String, dynamic>>(
                (reservation) => reservation as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to load reservations');
      }
    } catch (e) {
      print('Error fetching reservations: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading reservations'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No upcoming reservations'));
          }

          final reservations = snapshot.data!;

          return SingleChildScrollView(
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
                        'Upcoming Reservations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reservations.length,
                        itemBuilder: (context, index) {
                          final reservation = reservations[index];
                          return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ReservationCard(
                                creatorName:
                                    reservation['creatorName'] ?? 'Unknown',
                                creatorGender:
                                    reservation['creatorGender'] ?? 'Unknown',
                                creatorAge: reservation['creatorAge'] ?? 0,
                                reservationDate:
                                    reservation['date'] ?? 'N/A',
                                reservationTime:
                                    reservation['time'] ?? 'N/A',
                                slotsAvailable:
                                    reservation['slotsAvailable'] ?? 0,
                                maxSlots: reservation['maxSlots'] ?? 1,
                                creatorImagePath:
                                    reservation['creatorImagePath'] ??
                                        'assets/images/default.png',
                              ));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
