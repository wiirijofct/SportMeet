import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sport_meet/application/presentation/applogic/fields_service.dart';
import 'dart:convert';
import 'package:sport_meet/application/presentation/widgets/person_card.dart';
import 'package:sport_meet/application/presentation/applogic/auth.dart';

class ReservationPage extends StatefulWidget {
  final String reservationId;
  final String fieldId;

  const ReservationPage({
    Key? key,
    required this.reservationId,
    required this.fieldId,
  }) : super(key: key);

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late Future<Map<String, dynamic>> reservationInfo;
  late Future<Map<String, dynamic>> fieldInfo;
  late Future<Map<String, dynamic>> creatorInfo;
  late Future<List<Map<String, dynamic>>> joinedUsersInfo;

  @override
  void initState() {
    super.initState();
    reservationInfo = _fetchReservationInfo();
    fieldInfo = _fetchFieldInfo();
  }

  Future<Map<String, dynamic>> _fetchReservationInfo() async {
    final response = await http.get(Uri.parse('http://localhost:3000/reservations/${widget.reservationId}'));
    if (response.statusCode == 200) {
      final reservation = json.decode(utf8.decode(response.bodyBytes));
      creatorInfo = _fetchUserInfo(reservation['creatorId']);
      joinedUsersInfo = _fetchJoinedUsersInfo(reservation['joinedIds']);
      return reservation;
    } else {
      throw Exception('Failed to load reservation info');
    }
  }

  Future<Map<String, dynamic>> _fetchFieldInfo() async {
    final response = await http.get(Uri.parse('http://localhost:3000/fields/${widget.fieldId}'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load field info');
    }
  }

  Future<Map<String, dynamic>> _fetchUserInfo(String userId) async {
    final response = await http.get(Uri.parse('http://localhost:3000/users/$userId'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load user info');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchJoinedUsersInfo(List<dynamic> userIds) async {
    List<Map<String, dynamic>> users = [];
    for (String userId in userIds) {
      final userInfo = await _fetchUserInfo(userId);
      users.add(userInfo);
    }
    return users;
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  int _calculateAge(String birthDate) {
    final parts = birthDate.split('/');
    final day = int.tryParse(parts[0]) ?? 1;
    final month = int.tryParse(parts[1]) ?? 1;
    final year = int.tryParse(parts[2]) ?? 2000;
    final birth = DateTime(year, month, day);
    final today = DateTime.now();
    int age = today.year - birth.year;
    if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) {
      age--;
    }
    return age;
  }

  Future<void> _abandonReservation(BuildContext context, Map<String, dynamic> reservation) async {
  final user = await Authentication.getLoggedInUser();
  if (user == null) {
    return;
  }

  // Remove the reservation from the user's reservations
  user['reservations'].remove(reservation['reservationId'].toString());

  // Remove the user from the reservation's joinedIds
  reservation['joinedIds'].remove(user['id']);

  // Increment the available slots
  reservation['slotsAvailable'] += 1;

  try {
    // Update the reservation
    await FieldsService().updateReservation(
      reservation['reservationId'],
      reservation,
    );

    // Update the user data
    final userResponse = await Authentication.updateUser(
      user['id'],
      reservations: List<String>.from(user['reservations']),
    );

    if (!userResponse) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to abandon reservation. Please try again.')),
      );
    } else {
      // Update local user data
      await Authentication.saveLoggedInUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have successfully abandoned the reservation.')),
      );

      // Pop the context to return to the previous page with a result
      Navigator.of(context).pop(true);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to abandon reservation. Please try again.')),
    );
  }
}

  void _showAbandonDialog(BuildContext context, Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Abandon Reservation'),
          content: const Text('Are you sure you want to abandon this reservation?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _abandonReservation(context, reservation);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Details'),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: Future.wait([
          reservationInfo,
          fieldInfo,
          reservationInfo.then((reservation) => _fetchUserInfo(reservation['creatorId'])),
          reservationInfo.then((reservation) => _fetchJoinedUsersInfo(reservation['joinedIds']))
        ]).then((results) => {
          'reservation': results[0],
          'field': results[1],
          'creator': results[2],
          'joinedUsers': results[3],
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final reservation = snapshot.data!['reservation'];
          final field = snapshot.data!['field'];
          final creator = snapshot.data!['creator'];
          final joinedUsers = snapshot.data!['joinedUsers'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field and Reservation Info
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Field: ${field['name'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              field['images']?[0] ?? '',
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey,
                                  child: const Center(child: Text('No Image Available', style: TextStyle(color: Colors.white)))
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          _buildDetailRow('Location', field['location'] ?? 'N/A'),
                          _buildDetailRow('Sport', reservation['sport'] ?? 'N/A'),
                          _buildDetailRow('Date', reservation['date'] ?? 'N/A'),
                          _buildDetailRow('Time', reservation['time'] ?? 'N/A'),
                          _buildDetailRow('Slots Available', '${reservation['slotsAvailable'] ?? 'N/A'}'),
                          _buildDetailRow('Max Slots', '${reservation['maxSlots'] ?? 'N/A'}'),
                          Row(
                            children: [
                              Expanded(child: _buildDetailRow('Contact Email', field['contact']?['email'] ?? 'N/A')),
                              IconButton(
                                icon: const Icon(Icons.email, color: Colors.redAccent),
                                onPressed: () {
                                  // Implement email action
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: _buildDetailRow('Contact Phone', field['contact']?['phone'] ?? 'N/A')),
                              IconButton(
                                icon: const Icon(Icons.phone, color: Colors.redAccent),
                                onPressed: () {
                                  // Implement phone call action
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Event Owner Info
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Event Owner',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(creator['imagePath'] ?? ''),
                                radius: 40,
                                onBackgroundImageError: (_, __) {
                                  // Handle the error
                                },
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Name: ${creator['firstName'] ?? 'N/A'} ${creator['lastName'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                                    const SizedBox(height: 8),
                                    Text('Gender: ${creator['gender'] ?? 'N/A'}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                                    const SizedBox(height: 8),
                                    Text('Age: ${_calculateAge(creator['birthDate'] ?? '01/01/2000')}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                                    const SizedBox(height: 8),
                                    Text('Municipality: ${creator['municipality'] ?? 'N/A'}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                                    const SizedBox(height: 8),
                                    Text('Favorite Sports: ${creator['sports']?.join(', ') ?? 'N/A'}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // People Signed Up
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'People Signed Up',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: joinedUsers.length,
                            itemBuilder: (context, index) {
                              final user = joinedUsers[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: PersonCard(
                                    title: '${user['firstName'] ?? 'N/A'} ${user['lastName'] ?? 'N/A'}',
                                    address: user['municipality'] ?? 'N/A',
                                    availability: 'Age: ${_calculateAge(user['birthDate'] ?? '01/01/2000')}',
                                    sports: 'Sports: ${user['sports']?.join(', ') ?? 'N/A'}',
                                    imagePath: user['imagePath'] ?? '',
                                    gender: 'Gender: ${user['gender'] ?? 'N/A'}',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Abandon Reservation Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _showAbandonDialog(context, reservation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Abandon Reservation',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}