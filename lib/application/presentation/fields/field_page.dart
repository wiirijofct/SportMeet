import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sport_meet/application/presentation/applogic/fields_service.dart';
import 'package:sport_meet/application/presentation/fields/eventCreationPage.dart';
import 'package:sport_meet/application/presentation/widgets/reservation_card.dart';
import 'package:http/http.dart' as http;
import 'package:sport_meet/application/presentation/applogic/auth.dart';

class FieldPage extends StatefulWidget {
  final String fieldId;
  final String fieldName;
  final String location;
  final String imagePath;
  final String sport;
  final Map<String, dynamic> schedule;
  final String contactEmail;
  final String contactPhone;
  final String pricing;

  const FieldPage({
    Key? key,
    required this.fieldId,
    required this.fieldName,
    required this.location,
    required this.sport,
    required this.imagePath,
    required this.schedule,
    required this.contactEmail,
    required this.contactPhone,
    required this.pricing,
  }) : super(key: key);

  @override
  _FieldPageState createState() => _FieldPageState();
}

class _FieldPageState extends State<FieldPage> {
  late Future<List<Map<String, dynamic>>> _reservationsFuture;

  @override
  void initState() {
    super.initState();
    _reservationsFuture = _fetchReservations();
  }

  Future<List<Map<String, dynamic>>> _fetchReservations() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/reservations'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (data == null || data.isEmpty) {
          return [];
        }
        return data
            .where((reservation) =>
                reservation['fieldId'].toString() == widget.fieldId)
            .map<Map<String, dynamic>>((reservation) {
          final Map<String, dynamic> res = reservation as Map<String, dynamic>;
          res['joinedIds'] = List<String>.from(res['joinedIds'] ?? []);
          return res;
        }).toList();
      } else {
        throw Exception('Failed to load reservations');
      }
    } catch (e) {
      print('Error fetching reservations: $e');
      return [];
    }
  }

  Future<void> _handleJoinReservation(BuildContext context, Map<String, dynamic> reservation) async {
  final user = await Authentication.getLoggedInUser();
  if (user == null) {
    return;
  }

  // Check if the user has already joined the reservation
  if (user['reservations'].contains(reservation['reservationId'].toString())) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have already joined this reservation.')),
    );
    return;
  }

  if (reservation['slotsAvailable'] > 0) {
    final int newSlotsAvailable = reservation['slotsAvailable'] - 1; // Reduce available slots

    reservation['slotsAvailable'] = newSlotsAvailable;
    reservation['joinedIds'].add(user['id']); // Add user to joinedIds

    try {
      await FieldsService().updateReservation(
        reservation['reservationId'],
        reservation,
      );

      user['reservations'].add(reservation['reservationId'].toString());

      // Update user sports if the reservation sport is not already in the user's sports list
      List<String> userSports = List<String>.from(user['sports']);
      if (!userSports.contains(reservation['sport'])) {
        userSports.add(reservation['sport']);
      }

      // Update user data
      final userResponse = await Authentication.updateUser(
        user['id'],
        reservations: List<String>.from(user['reservations']),
        sports: userSports,
      );

      if (!userResponse) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join reservation. Please try again.')),
        );
      } else {
        // Update local user data
        final updatedUser = {
          ...user,
          "reservations": List<String>.from(user['reservations']),
          "sports": userSports,
        };
        await Authentication.saveLoggedInUser(updatedUser);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have successfully joined the reservation!')),
        );
        setState(() {
          _reservationsFuture = _fetchReservations();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join reservation. Please try again.')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No slots available for this reservation.')),
    );
  }
}

  void _showJoinDialog(BuildContext context, Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Reservation'),
          content: const Text('Do you want to join this reservation?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Join'),
              onPressed: () {
                Navigator.of(context).pop();
                _handleJoinReservation(context, reservation);
              },
            ),
          ],
        );
      },
    );
  }

  String _formatSchedule(Map<String, dynamic> schedule) {
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    String formattedSchedule = '';
    for (var day in daysOfWeek) {
      if (schedule.containsKey(day)) {
        final daySchedule = schedule[day];
        if (daySchedule is Map<String, String>) {
          formattedSchedule +=
              '$day: ${daySchedule['Opens']} - ${daySchedule['Closes']}\n';
        } else if (daySchedule is bool && !daySchedule) {
          formattedSchedule += '$day: Closed\n';
        }
      }
    }
    return formattedSchedule.trim();
  }

  Future<void> _navigateToEventCreationPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventCreationPage(
          fieldId: widget.fieldId,
          sport: widget.sport,
          fieldName: widget.fieldName,
          location: widget.location,
          imagePath: widget.imagePath,
          schedule: widget.schedule,
          contactEmail: widget.contactEmail,
          contactPhone: widget.contactPhone,
          pricing: widget.pricing,
        ),
      ),
    );

    if (result == true) {
      // Recarregar a lista de reservas
      setState(() {
        _reservationsFuture = _fetchReservations();
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              widget.imagePath,
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
                    widget.fieldName,
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
                          widget.location,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFieldDetailRow(
                    icon: Ionicons.time_outline,
                    title: 'Schedule',
                    detail: _formatSchedule(widget.schedule),
                  ),
                  const SizedBox(height: 8),
                  _buildFieldDetailRow(
                    icon: Ionicons.mail_outline,
                    title: 'Email',
                    detail: widget.contactEmail,
                  ),
                  const SizedBox(height: 8),
                  _buildFieldDetailRow(
                    icon: Ionicons.call_outline,
                    title: 'Phone',
                    detail: widget.contactPhone,
                  ),
                  const SizedBox(height: 8),
                  _buildFieldDetailRow(
                    icon: Ionicons.cash_outline,
                    title: 'Pricing per hour',
                    detail: widget.pricing,
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
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _reservationsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading reservations'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No upcoming reservations'));
                      }

                      final reservations = snapshot.data!;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reservations.length,
                        itemBuilder: (context, index) {
                          final reservation = reservations[index];
                          return GestureDetector(
                            onTap: () {
                              _showJoinDialog(context, reservation);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ReservationCard(
                                reservationDate: reservation['date'] ?? 'N/A',
                                reservationTime: reservation['time'] ?? 'N/A',
                                slotsAvailable:
                                    reservation['slotsAvailable'] ?? 0,
                                maxSlots: reservation['maxSlots'] ?? 1,
                                creatorId: reservation['creatorId'] ?? 'N/A',
                                joinedIds: List<String>.from(
                                    reservation['joinedIds'] ?? []),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToEventCreationPage,
        child: const Icon(Ionicons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
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
