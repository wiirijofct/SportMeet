// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'dart:convert';
import 'package:sport_meet/application/applogic/auth.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

void main() async {}

class User {
  // Variable to store user info without needing to fetch it again
  static Map<String, dynamic> info = {};

  static Future<Map<String, dynamic>> getInfo() async {
    String url = '${Authentication.getUrl()}/user/info';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        info = jsonDecode(response.body);
        return info;
      } else {
        print(response.statusCode);
        return {};
      }
    } catch (e) {
      print(e);
      return {};
    }
  }

  static Future<Map<String, dynamic>> getProfileInfo(String username) async {
    String url = '${Authentication.getUrl()}/user/profile?username=$username';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(response.statusCode);
        return {};
      }
    } catch (e) {
      print(e);
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getFriends(String username) async {
    String url = '${Authentication.getUrl()}/friends/list?username=$username';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        print(response.statusCode);
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<bool> addFriend(String friendUsername) async {
    String url = '${Authentication.getUrl()}/friends/add';
    try {
      final response = await http.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': friendUsername}));

      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> removeFriend(String friendUsername) async {
    String url = '${Authentication.getUrl()}/friends/remove';
    try {
      final response = await http.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': friendUsername}));

      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> updateInfo(String username, String email, String name,
      String countryCode, String phone, String profile) async {
    String url = '${Authentication.getUrl()}/user';

    final data = {
      "targetUsername": username,
      "email": email,
      "name": name,
      "countryCode": countryCode,
      "phoneNumber": phone,
      "isProfilePublic": profile == 'Public' ? true : false,
    };

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> updatePassword(String oldPassword, String newPassword) async {
    String url = '${Authentication.getUrl()}/user/updatePassword';

    final data = {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
    };

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> uploadProfilePicture(Uint8List file) async {
    String url = '${Authentication.getUrl()}/user/uploadProfilePicture';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(http.MultipartFile.fromBytes('file', file,
          filename: 'profile.png', contentType: MediaType('image', 'png')));
      request.fields['username'] = info['username'];

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<Map<String, Map<String, dynamic>>> getUserList() async {
    String url = '${Authentication.getUrl()}/users';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value as Map<String, dynamic>));
      } else {
        print(response.statusCode);
        return {};
      }
    } catch (e) {
      print(e);
      return {};
    }
  }
}
