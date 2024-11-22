import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sport_meet/application/presentation/widgets/person_card.dart';

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
                  Text(
                    'Field: ${field['name']}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Image.network(field['images'][0], height: 200, fit: BoxFit.cover),
                  const SizedBox(height: 16),
                  Text('Location: ${field['location']}'),
                  const SizedBox(height: 16),
                  Text('Sport: ${reservation['sport']}'),
                  const SizedBox(height: 16),
                  Text('Date: ${reservation['date']}'),
                  const SizedBox(height: 16),
                  Text('Time: ${reservation['time']}'),
                  const SizedBox(height: 16),
                  Text('Slots Available: ${reservation['slotsAvailable']}'),
                  const SizedBox(height: 16),
                  Text('Max Slots: ${reservation['maxSlots']}'),
                  const SizedBox(height: 16),
                  Text('Contact Email: ${field['contact']['email']}'),
                  const SizedBox(height: 16),
                  Text('Contact Phone: ${field['contact']['phone']}'),
                  const SizedBox(height: 32),

                  // Event Owner Info
                  Text(
                    'Event Owner',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(creator['imagePath']),
                        radius: 40,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${creator['firstName']} ${creator['lastName']}'),
                          const SizedBox(height: 8),
                          Text('Gender: ${creator['gender']}'),
                          const SizedBox(height: 8),
                          Text('Age: ${_calculateAge(creator['birthDate'])}'),
                          const SizedBox(height: 8),
                          Text('Municipality: ${creator['municipality']}'),
                          const SizedBox(height: 8),
                          Text('Favorite Sports: ${creator['sports'].join(', ')}'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // People Signed Up
                  Text(
                    'People Signed Up',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: joinedUsers.length,
                    itemBuilder: (context, index) {
                      final user = joinedUsers[index];
                      return PersonCard(
                        title: '${user['firstName']} ${user['lastName']}',
                        address: user['municipality'],
                        availability: 'Age: ${_calculateAge(user['birthDate'])}',
                        sports: 'Sports: ${user['sports'].join(', ')}',
                        imagePath: user['imagePath'],
                        gender: 'Gender: ${user['gender']}',
                      );
                    },
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