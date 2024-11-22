import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';

class EventCreationPage extends StatefulWidget {
  final String fieldId;
  final String fieldName;
  final String sport;
  final String location;
  final String imagePath;
  final Map<String, dynamic> schedule;
  final String contactEmail;
  final String contactPhone;
  final String pricing;

  const EventCreationPage({
    Key? key,
    required this.fieldId,
    required this.fieldName,
    required this.sport,
    required this.location,
    required this.imagePath,
    required this.schedule,
    required this.contactEmail,
    required this.contactPhone,
    required this.pricing,
  }) : super(key: key);

  @override
  State<EventCreationPage> createState() => _EventCreationPageState();
}

class _EventCreationPageState extends State<EventCreationPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isSubmitting = false;

  static const String apiUrl = "http://localhost:3000";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
   
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitReservation() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userInfo = await User.getInfo();
      if (userInfo == null) {
        throw Exception('User not authenticated.');
      }

      final userId = userInfo['id'].toString();
      final creatorName = "${userInfo['firstName']} ${userInfo['lastName']}";
      final creatorGender = userInfo['gender'];
      final birthDate = userInfo['birthDate'];
      final creatorAge = _calculateAge(birthDate);
      final creatorImagePath = userInfo['imagePath'];

      final reservationsResponse =
          await http.get(Uri.parse('$apiUrl/reservations'));
      if (reservationsResponse.statusCode != 200) {
        throw Exception('Failed to fetch reservations.');
      }

      final List<dynamic> reservationsData =
          json.decode(utf8.decode(reservationsResponse.bodyBytes));
      int lastReservationId = 100;
      if (reservationsData.isNotEmpty) {
        lastReservationId = reservationsData
            .map((res) => int.parse(res['reservationId']))
            .reduce((a, b) => a > b ? a : b);
      }
      final newReservationId = (lastReservationId + 1).toString();

      final int maxSlots = 5;
      final fieldReservations = reservationsData
          .where((res) => res['fieldId'].toString() == widget.fieldId)
          .toList();

      final usersResponse = await http.get(Uri.parse('$apiUrl/users'));
      if (usersResponse.statusCode != 200) {
        throw Exception('Failed to fetch users.');
      }
      
      final slotsAvailable = maxSlots - 1;

      final formattedDate = _formatDate(_selectedDate!);
      final formattedTime = _selectedTime!.format(context);

      final newReservation = {
        "id": newReservationId,
        "reservationId": newReservationId,
        "fieldId": widget.fieldId,
        "sport": widget.sport,
        "date": formattedDate,
        "time": formattedTime,
        "creatorName": creatorName,
        "creatorGender": creatorGender,
        "creatorAge": creatorAge,
        "slotsAvailable": slotsAvailable,
        "maxSlots": maxSlots,
        "creatorImagePath": creatorImagePath,
      };

      final addReservationResponse = await http.post(
        Uri.parse('$apiUrl/reservations'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newReservation),
      );

      if (addReservationResponse.statusCode != 201) {
        throw Exception('Failed to create reservation.');
      }

      final updatedUserReservations =
          List<String>.from(userInfo['reservations']);
      updatedUserReservations.add(newReservationId);

      final updatedUser = {
        ...userInfo,
        "reservations": updatedUserReservations,
      };

      final updateUserResponse = await http.put(
        Uri.parse('$apiUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedUser),
      );

      if (updateUserResponse.statusCode != 200) {
        throw Exception('Failed to update user reservations.');
      }

      await Authentication.saveLoggedInUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation successfully created!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating reservation: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        'Create Reservation for ${widget.fieldName}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            hintText: 'Select the date',
                            suffixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (_selectedDate == null) {
                              return 'Please select a date.';
                            }
                            return null;
                          },
                          controller: TextEditingController(
                            text: _selectedDate == null
                                ? ''
                                : _formatDate(_selectedDate!)
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Time',
                            hintText: 'Select the time',
                            suffixIcon: const Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (_selectedTime == null) {
                              return 'Please select a time.';
                            }
                            return null;
                          },
                          controller: TextEditingController(
                            text: _selectedTime == null
                                ? ''
                                : _selectedTime!.format(context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: _submitReservation,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 32.0),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Create Reservation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
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
        'Create Reservation',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}