import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication {
  static const int minPasswordLength = 8;
  static bool _isCreatingUser = false;
  static const String apiUrl =
      "http://localhost:3000"; // Replace with your json-server endpoint

  static bool isPasswordCompliant(String password) {
    if (password.isEmpty) return false;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#\\$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length > minPasswordLength;

    return hasDigits &&
        hasUppercase &&
        hasLowercase &&
        hasSpecialCharacters &&
        hasMinLength;
  }

  static bool isEmailCompliant(String email, [int minLength = 3]) {
    if (email.isEmpty) return false;

    bool hasAt = email.contains(RegExp(r'[@]'));
    bool hasDomain = email.contains(RegExp(r'[.]'));
    bool hasMinLength = email.length > minLength;

    return hasAt && hasMinLength && hasDomain;
  }

  static Future<bool> createUser(String username, String email, String name, String lastName,
      String phone, String birthDate, List<String> sports, String password, bool hostUser) async {
    if (_isCreatingUser) {
      return false; // If a user is already being created, return false
    }

    _isCreatingUser = true; // Set flag to indicate user creation in progress

    try {
      // Check if username or email already exists
      final response = await http.get(Uri.parse('$apiUrl/users'));
      if (response.statusCode == 200) {
        List<dynamic> users = json.decode(response.body);
        for (var user in users) {
          if (user['username'] == username || user['email'] == email) {
            print('User already exists: $user');
            _isCreatingUser = false; // Reset flag before returning
            return false; // User already exists
          }
        }
      } else {
        throw Exception('Failed to load users');
      }

      // Add new user
      final newUser = {
        "userId": DateTime.now().millisecondsSinceEpoch, // Generate a unique ID
        "username": username,
        "firstName": name,
        "lastName": lastName,
        "email": email,
        "password": password,
        "phone": phone,
        "birthDate": birthDate,
        "sports": sports,
        "favFields": [],
        "reservations": [],
        "friends": [],
        "imagePath": "lib/images/m1.png",
        "hostUser": hostUser,
      };

      final createResponse = await http.post(
        Uri.parse('$apiUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newUser),
      );

      if (createResponse.statusCode == 201) {
        print('User created: $newUser');
        return true;
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      print('Error creating user: $e');
      return false;
    } finally {
      _isCreatingUser = false; // Reset flag after user creation is complete
    }
  }

  static Future<bool> loginUser(
      String username, String password, bool isPermanent) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/users'));
      if (response.statusCode == 200) {
        List<dynamic> users = json.decode(response.body);

        for (var user in users) {
          if (user['username'] == username && user['password'] == password) {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.setString('loggedInUser', jsonEncode(user));
            if (isPermanent) {
              await saveLoggedInUser(user);
            }
            return true;
          }
        }
      }
      return false; // No matching user found
    } catch (e) {
      print('Error logging in user: $e');
      return false;
    }
  }

  static Future<void> saveLoggedInUser(Map<String, dynamic> user) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('loggedInUser', jsonEncode(user));
      print('Logged-in user saved to SharedPreferences.');
    } catch (e) {
      print('Error saving logged-in user: $e');
    }
  }

  static Future<Map<String, dynamic>?> getLoggedInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userJson = prefs.getString('loggedInUser');
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  static Future<bool> logoutUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove('loggedInUser');
  }

  static Future<String?> resetPassword(String username, String email) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/users'));
      if (response.statusCode == 200) {
        List<dynamic> users = json.decode(response.body);

        for (var user in users) {
          if (user['username'] == username && user['email'] == email) {
            user['password'] = 'newpassword123';

            final updateResponse = await http.put(
              Uri.parse('$apiUrl/users/${user['userId']}'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(user),
            );

            if (updateResponse.statusCode == 200) {
              return null; // Success
            } else {
              throw Exception('Failed to update user password');
            }
          }
        }
      }
      return 'User not found';
    } catch (e) {
      print('Error resetting password: $e');
      return 'Error resetting password';
    }
  }

  static Future<bool> deleteAccount(String username) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/users'));
      if (response.statusCode == 200) {
        List<dynamic> users = json.decode(response.body);

        var user = users.firstWhere((user) => user['username'] == username,
            orElse: () => null);
        if (user != null) {
          final deleteResponse =
              await http.delete(Uri.parse('$apiUrl/users/${user['userId']}'));

          if (deleteResponse.statusCode == 200) {
            return true;
          } else {
            throw Exception('Failed to delete user');
          }
        }
      }
      return false;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  static Future<List<String>> getUserSports() async {
    final loggedInUser = await getLoggedInUser();
    if (loggedInUser == null) {
      return [];
    }
    return List<String>.from(loggedInUser['sports']);
  }

  static Future<List<Map<String, dynamic>>> getUserReservations() async {
    final loggedInUser = await getLoggedInUser();
    if (loggedInUser == null) {
      return [];
    }

    try {
      final response = await http.get(Uri.parse('$apiUrl/reservations'));
      if (response.statusCode == 200) {
        List<dynamic> reservations = json.decode(response.body);
        List<String> userReservationIds =
            List<String>.from(loggedInUser['reservations']);
        List<Map<String, dynamic>> userReservations = reservations
            .where((reservation) => userReservationIds
                .contains(reservation['reservationId'].toString()))
            .map((reservation) => Map<String, dynamic>.from(reservation))
            .toList();

        print('User reservation IDs: $userReservationIds');
        print('All reservations: $reservations');
        print('User reservations: $userReservations');
        return userReservations;
      } else {
        throw Exception('Failed to load reservations');
      }
    } catch (e) {
      print('Error loading reservations: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getFieldById(String fieldId) async {
    try {
      print('Loading field with ID: $fieldId');
      final response = await http.get(Uri.parse('$apiUrl/fields/$fieldId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Field with ID $fieldId not found');
      } else {
        throw Exception(
            'Failed to load field with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading field: $e');
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getUserEvents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await loadFieldsAndReservations();

    final loggedInUser = await getLoggedInUser();
    if (loggedInUser == null) {
      return [];
    }

    String? reservationsJson = prefs.getString('reservations');
    List<dynamic> reservations =
        reservationsJson != null ? jsonDecode(reservationsJson) : [];

    List<String> userReservationIds = List<String>.from(loggedInUser['reservations']);
    List<Map<String, dynamic>> userReservations = reservations
        .where((reservation) => userReservationIds
            .contains(reservation['reservationId']))
        .map((reservation) => Map<String, dynamic>.from(reservation))
        .toList();

    print('User reservation IDs: \$userReservationIds');
    print('All reservations: \$reservations');
    print('User events loaded: \$userReservations');
    return userReservations;
  }

  static Future<List<Map<String, dynamic>>> getFilteredEvents(
      List<String> selectedSports) async {
    List<Map<String, dynamic>> userEvents = await getUserEvents();
    List<Map<String, dynamic>> filteredEvents = userEvents
        .where((event) => selectedSports.contains(event['sport']))
        .toList();

    print('Filtered events based on sports selection: \$filteredEvents');
    return filteredEvents;
  }

  static Future<Map<String, dynamic>?> getFieldForEvent(
      Map<String, dynamic> event) async {
    return await getFieldById(event['fieldId'].toString());
  }

  static Future<List<Map<String, dynamic>>> getCompleteEventDetails(
      List<Map<String, dynamic>> events) async {
    List<Map<String, dynamic>> completeEvents = [];
    for (var event in events) {
      print('Processing event: \$event');
      var field = await getFieldForEvent(event);
      if (field != null && field.isNotEmpty) {
        completeEvents.add({...event, ...field});
      }
    }
    print('Complete event details with field data: \$completeEvents');
    return completeEvents;
  }

  static Future<List<Map<String, dynamic>>> getUserFilteredCompleteEvents(
      List<String> selectedSports) async {
    List<Map<String, dynamic>> filteredEvents =
        await getFilteredEvents(selectedSports);
    return await getCompleteEventDetails(filteredEvents);
  }

  static Future<void> initializeUsers() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/users'));
      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('users', response.body);
      } else {
        throw Exception('Failed to initialize users');
      }
    } catch (e) {
      print('Error initializing users: $e');
    }
  }

  static Future<bool> isHostUser() async {
    final loggedInUser = await getLoggedInUser();
    return loggedInUser?['hostUser'] ?? false;
  }

  static Future<void> loadFieldsAndReservations() async {
    try {
      // Load fields data
      final fieldsResponse = await http.get(Uri.parse('$apiUrl/fields'));
      if (fieldsResponse.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('fields', fieldsResponse.body);
        print('Fields data loaded successfully.');
      } else {
        throw Exception('Failed to load fields');
      }
    } catch (e) {
      print('Error loading fields: $e');
    }

    try {
      // Load reservations data
      final reservationsResponse =
          await http.get(Uri.parse('$apiUrl/reservations'));
      if (reservationsResponse.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('reservations', reservationsResponse.body);
        print('Reservations data loaded successfully.');
      } else {
        throw Exception('Failed to load reservations');
      }
    } catch (e) {
      print('Error loading reservations: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Authentication.initializeUsers();
}
