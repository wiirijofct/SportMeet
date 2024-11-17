import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

class Authentication {
  static const int minPasswordLength = 8;

  static bool isPasswordCompliant(String password) {
    if (password.isEmpty) return false;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
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

  static Future<bool> createUser(String username, String email, String name,
      String countryCode, String phone, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load users from shared preferences
    String? usersJson = prefs.getString('users');
    List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

    // Check if username or email already exists
    for (var user in users) {
      if (user['username'] == username || user['email'] == email) {
        return false; // User already exists
      }
    }

    // Add new user
    users.add({
      "userId": users.length + 1,
      "username": username,
      "email": email,
      "name": name,
      "countryCode": countryCode,
      "phoneNumber": phone,
      "password": password,
      "isProfilePublic": false,
    });

    // Save updated users list
    prefs.setString('users', jsonEncode(users));
    return true;
  }

  static Future<bool> loginUser(
    String username, String password, bool isPermanent) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Load users from shared preferences
  String? usersJson = prefs.getString('users');
  List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

  // Debug print statements
  print('Loaded users: $users');
  print('Trying to log in with username: $username, password: $password');

  // Check for matching user
  for (var user in users) {
    if (user['username'] == username && user['password'] == password) {
      // Save logged-in user
      prefs.setString('loggedInUser', jsonEncode(user));
      return true;
    }
  }
  return false; // No matching user found
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load users from shared preferences
    String? usersJson = prefs.getString('users');
    List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

    // Find the user and reset password
    for (var user in users) {
      if (user['username'] == username && user['email'] == email) {
        // Reset password logic (for example, setting a default password)
        user['password'] = 'newpassword123';

        // Save updated users list
        prefs.setString('users', jsonEncode(users));
        return null; // Success
      }
    }
    return 'User not found';
  }

  static Future<bool> deleteAccount(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load users from shared preferences
    String? usersJson = prefs.getString('users');
    List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

    // Find and remove the user
    users.removeWhere((user) => user['username'] == username);

    // Save updated users list
    prefs.setString('users', jsonEncode(users));
    return true;
  }

  static Future<List<dynamic>> loadUsers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('users');
    return usersJson != null ? jsonDecode(usersJson) : [];
  }

  static Future<List<Map<String, dynamic>>> getUserReservations() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load logged-in user info
    String? userJson = prefs.getString('loggedInUser');
    if (userJson == null) {
      return [];
    }
    Map<String, dynamic> loggedInUser = jsonDecode(userJson);

    // Load reservations from JSON file or SharedPreferences
    String reservationsJson = await rootBundle.loadString('assets/data/reservations.json');
    List<dynamic> reservations = jsonDecode(reservationsJson);

    // Filter reservations for the logged-in user
    List<int> userReservationIds = List<int>.from(loggedInUser['reservations']);
    List<Map<String, dynamic>> userReservations = reservations
        .where((reservation) => userReservationIds.contains(int.parse(reservation['reservationId'])))
        .map((reservation) => Map<String, dynamic>.from(reservation))
        .toList();

    print('User reservation IDs: \$userReservationIds');
    print('All reservations: \$reservations');
    print('User reservations: \$userReservations');
    return userReservations;
  }

  static Future<void> loadFieldsAndReservations() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load reservations data from JSON file or SharedPreferences
    String reservationsJson = await rootBundle.loadString('assets/data/reservations.json');
    prefs.setString('reservations', reservationsJson);

    // Load fields data from JSON file or SharedPreferences
    String fieldsJson = await rootBundle.loadString('assets/data/fields.json');
    prefs.setString('fields', fieldsJson);
  }

  static Future<List<Map<String, dynamic>>> getUserEvents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await loadFieldsAndReservations();

    // Load logged-in user info
    String? userJson = prefs.getString('loggedInUser');
    if (userJson == null) {
      return [];
    }
    Map<String, dynamic> loggedInUser = jsonDecode(userJson);

    // Load reservations from SharedPreferences
    String? reservationsJson = prefs.getString('reservations');
    List<dynamic> reservations = reservationsJson != null ? jsonDecode(reservationsJson) : [];

    List<int> userReservationIds = List<int>.from(loggedInUser['reservations']);
    List<Map<String, dynamic>> userReservations = reservations
        .where((reservation) => userReservationIds.contains(int.parse(reservation['reservationId'])))
        .map((reservation) => Map<String, dynamic>.from(reservation))
        .toList();

    print('User reservation IDs: \$userReservationIds');
    print('All reservations: \$reservations');
    print('User events loaded: \$userReservations');
    return userReservations;
  }

  static Future<Map<String, dynamic>> getFieldById(int fieldId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load fields from SharedPreferences
    String? fieldsJson = prefs.getString('fields');
    List<dynamic> fields = fieldsJson != null ? jsonDecode(fieldsJson) : [];

    print('All fields: \$fields');
    return fields.firstWhere((field) => int.parse(field['fieldId']) == fieldId, orElse: () => {});
  }

  static Future<List<Map<String, dynamic>>> getFilteredEvents(List<String> selectedSports) async {
    List<Map<String, dynamic>> userEvents = await getUserEvents();
    List<Map<String, dynamic>> filteredEvents = userEvents
        .where((event) => selectedSports.contains(event['sport']))
        .toList();

    print('Filtered events based on sports selection: \$filteredEvents');
    return filteredEvents;
  }

  static Future<Map<String, dynamic>?> getFieldForEvent(Map<String, dynamic> event) async {
    return await getFieldById(int.parse(event['fieldId']));
  }

  static Future<List<Map<String, dynamic>>> getCompleteEventDetails(List<Map<String, dynamic>> events) async {
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

  static Future<List<Map<String, dynamic>>> getUserFilteredCompleteEvents(List<String> selectedSports) async {
    List<Map<String, dynamic>> filteredEvents = await getFilteredEvents(selectedSports);
    return await getCompleteEventDetails(filteredEvents);
  }

  static Future<void> initializeUsers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('users');

    // If users data does not exist, initialize it with static content
    if (usersJson == null) {
      String jsonString = await rootBundle.loadString('assets/data/users.json');
      prefs.setString('users', jsonString);
    }
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Authentication.initializeUsers();
}
