import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sport_meet/application/presentation/applogic/user.dart';
import 'package:intl/intl.dart';

class FieldsService {
  late Future<Map<String, dynamic>> userInfo;
  late String username;
  late String id;
  static const String apiUrl = "http://localhost:3000";

  FieldsService() {
    userInfo = User.getInfo();
    userInfo.then((info) {
      username = info['username'];
      id = info['id'];
    });
  }

  Future<List<Map<String, dynamic>>> fetchFields() async {
    final response = await http.get(Uri.parse('$apiUrl/fields'));
    if (response.statusCode == 200) {
      List<dynamic> fields = json.decode(utf8.decode(response.bodyBytes));
      return fields.map((field) {
        return {
          'id': field['id'] ?? '',
          'fieldId': field['fieldId'] ?? '',
          'ownerId': field['ownerId'] ?? '',
          'sport': field['sport'] ?? '',
          'name': field['name'] ?? '',
          'street': field['street'] ?? '',
          'location': field['location'] ?? '',
          'coordinates': field['coordinates'] ?? {'lat': 0.0, 'lon': 0.0},
          'schedule': field['schedule'] ?? {},
          'unavailability': List<String>.from(field['unavailability'] ?? []),
          'isPublic': field['isPublic'] ?? false,
          'pricing': field['pricing'] ?? '',
          'contact': field['contact'] ?? {'email': '', 'phone': ''},
          'description': field['description'] ?? '',
          'images': List<String>.from(field['images'] ?? []),
        };
      }).toList();
    } else {
      throw Exception('Failed to load fields');
    }
  }

  Future<void> addField(Map<String, dynamic> fieldData) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/fields'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(fieldData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add field');
    }
  }

  Future<void> updateField(
      String fieldId, Map<String, dynamic> fieldData) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/fields/$fieldId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(fieldData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update field');
    }
  }

  Future<void> updateReservation(
    String reservationId, Map<String, dynamic> reservationData) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/reservations/$reservationId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reservationData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update reservation');
    }
  }

  Future<void> deleteField(String fieldId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/fields/$fieldId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete field');
    }
  }

  Future<List<dynamic>> fetchAvailableSports() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/sports'));
      if (response.statusCode == 200) {
        final List<dynamic> sportsList =
            json.decode(utf8.decode(response.bodyBytes));
        return sportsList.map((sport) => sport['name']).toList();
      } else {
        throw Exception('Failed to load available sports');
      }
    } catch (e) {
      print('Error loading available sports: $e');
      throw Exception('Failed to load available sports');
    }
  }

  List<String> getUniqueSports(List<dynamic> fields) {
    final sports = fields
        .map((field) => field['sport'])
        .toSet()
        .map((sport) => sport.toString())
        .toList();
    sports.sort();
    return sports;
  }

  Future<List<dynamic>> fetchReservations() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/reservations'));
      if (response.statusCode == 200) {
        final List<dynamic> reservations =
            json.decode(utf8.decode(response.bodyBytes));
        return reservations;
      } else {
        throw Exception('Failed to load reservations');
      }
    } catch (e) {
      print('Error loading reservations: $e');
      throw Exception('Failed to load reservations');
    }
  }

  List<dynamic> getFieldsByReservations(List<dynamic> fields,
      List<dynamic> reservations, TimeOfDay selectedTime) {
    // Format the selected time to a string
    final selectedTimeString = DateFormat.jm()
        .format(DateTime(0, 1, 1, selectedTime.hour, selectedTime.minute));

    // Normalize the formatted time string to remove non-breaking spaces
    final normalizedSelectedTimeString =
        selectedTimeString.replaceAll('\u202F', ' ').trim();

    // Find reservations that match the selected time
    final matchingReservations = reservations.where((reservation) {
      final reservationTime =
          reservation['time'].replaceAll('\u202F', ' ').trim();
      return reservationTime == normalizedSelectedTimeString;
    }).toList();

    // Get the field IDs of the matching reservations
    final matchingFieldIds = matchingReservations
        .map((reservation) => reservation['fieldId'])
        .toSet();

    // Filter fields that have matching field IDs
    return fields
        .where((field) => matchingFieldIds.contains(field['id']))
        .toList();
  }
}
