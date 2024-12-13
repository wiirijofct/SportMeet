import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {}

class User {
  // Variable to store user info without needing to fetch it again
  static Map<String, dynamic> info = {};

  static Future<Map<String, dynamic>> getInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('loggedInUser');
    if (userJson != null) {
      info = jsonDecode(userJson);
      return info;
    }
    return {};
  }

  static Future<Map<String, dynamic>> getProfileInfo(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('users');
    List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

    for (var user in users) {
      if (user['username'] == username) {
        return user;
      }
    }
    return {};
  }

  static Future<List<Map<String, dynamic>>> getFriends(String username) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? usersJson = prefs.getString('users');
  List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

  for (var user in users) {
    if (user['username'] == username) {
      List<String> friendsIds = List<String>.from(user['friends']);
      return users
          .where((u) => friendsIds.contains(u['userId'].toString()))
          .map((u) => Map<String, dynamic>.from(u))
          .toList();
    }
  }
  return [];
}

  static Future<bool> addFriend(String friendUsername) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('users');
    List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

    String? loggedInUserJson = prefs.getString('loggedInUser');
    if (loggedInUserJson == null) return false;

    Map<String, dynamic> loggedInUser = jsonDecode(loggedInUserJson);

    for (var user in users) {
      if (user['username'] == friendUsername) {
        loggedInUser['friends'].add(user['userId']);
        prefs.setString('loggedInUser', jsonEncode(loggedInUser));
        prefs.setString('users', jsonEncode(users));
        return true;
      }
    }
    return false;
  }

  static Future<bool> removeFriend(String friendUsername) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('users');
    List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

    String? loggedInUserJson = prefs.getString('loggedInUser');
    if (loggedInUserJson == null) return false;

    Map<String, dynamic> loggedInUser = jsonDecode(loggedInUserJson);

    for (var user in users) {
      if (user['username'] == friendUsername) {
        loggedInUser['friends'].remove(user['userId']);
        prefs.setString('loggedInUser', jsonEncode(loggedInUser));
        prefs.setString('users', jsonEncode(users));
        return true;
      }
    }
    return false;
  }

  static Future<bool> updateInfo(String username, String email, String name,
      String countryCode, String phone, String profile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('users');
    List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

    String? loggedInUserJson = prefs.getString('loggedInUser');
    if (loggedInUserJson == null) return false;

    Map<String, dynamic> loggedInUser = jsonDecode(loggedInUserJson);

    loggedInUser['email'] = email;
    loggedInUser['name'] = name;
    loggedInUser['countryCode'] = countryCode;
    loggedInUser['phoneNumber'] = phone;
    loggedInUser['isProfilePublic'] = profile == 'Public';

    // Update users list
    for (int i = 0; i < users.length; i++) {
      if (users[i]['username'] == username) {
        users[i] = loggedInUser;
        break;
      }
    }

    prefs.setString('loggedInUser', jsonEncode(loggedInUser));
    prefs.setString('users', jsonEncode(users));
    return true;
  }

  static Future<bool> updatePassword(String oldPassword, String newPassword) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedInUserJson = prefs.getString('loggedInUser');
    if (loggedInUserJson == null) return false;

    Map<String, dynamic> loggedInUser = jsonDecode(loggedInUserJson);

    if (loggedInUser['password'] == oldPassword) {
      loggedInUser['password'] = newPassword;
      prefs.setString('loggedInUser', jsonEncode(loggedInUser));

      // Update users list
      String? usersJson = prefs.getString('users');
      List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];
      for (int i = 0; i < users.length; i++) {
        if (users[i]['username'] == loggedInUser['username']) {
          users[i] = loggedInUser;
          break;
        }
      }
      prefs.setString('users', jsonEncode(users));
      return true;
    }
    return false;
  }

  static Future<bool> updateProfilePicture(String imagePath, profileImage) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedInUserJson = prefs.getString('loggedInUser');
    if (loggedInUserJson == null) return false;

    Map<String, dynamic> loggedInUser = jsonDecode(loggedInUserJson);
    loggedInUser['imagePath'] = imagePath;

    prefs.setString('loggedInUser', jsonEncode(loggedInUser));
    return true;
  }

  static Future<Map<String, Map<String, dynamic>>> getUserList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('users');
    List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];

    return {for (var user in users) user['username']: user};
  }
}
