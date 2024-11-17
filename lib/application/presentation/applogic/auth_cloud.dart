// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class Authentication {
  static const int minPasswordLength = 8;

  // Set the base URL for mobile-only
  static String getUrl() {
    return "https://deployedapp.com/rest";
  }

  static bool isPasswordCompliant(String password) {
    if (password.isEmpty) return false;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
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

  static Future<String?> createUser(String username, String email, String name,
      String countryCode, String phone, String password) async {
    String url = '${getUrl()}/register';

    final data = {
      "username": username,
      "email": email,
      "name": name,
      "countryCode": countryCode,
      "phoneNumber": phone,
      "password": password,
      "isProfilePublic": false,
    };

    print('Create User Data: $data');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      return response.statusCode == 200 ? null : response.body;
    } catch (e) {
      print('Create User Error: $e');
      return null;
    }
  }

  static Future<MemoryImage?> downloadImage(String imgName) async {
    String url =
        "https://storage.googleapis.com/download/storage/v1/b/ecotrecko.appspot.com/o/default?generation=1712598515569846&alt=media";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        return MemoryImage(Uint8List.fromList(bytes));
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<String?> uploadImage(String username, Uint8List imgFile) async {
    String url = '${getUrl()}/user/uploadProfilePicture';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['username'] = username
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            imgFile,
            filename: 'profile.png',
            contentType: MediaType('image', 'png'),
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200
          ? jsonDecode(response.body)['imageUrl']
          : null;
    } catch (e) {
      print('Upload Image Error: $e');
      return null;
    }
  }

  static Future<bool> updateUserProfilePic(
      String username, String profilePicUrl) async {
    String url = '${getUrl()}/user/updateProfilePic';

    final data = {
      "username": username,
      "profilePicUrl": profilePicUrl,
    };

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update User Profile Pic Error: $e');
      return false;
    }
  }

  static Future<bool> loginUser(
      String username, String password, bool isPermanent) async {
    String url = '${getUrl()}/login';

    final data = {
      'username': username,
      'password': password,
      'isPermanent': isPermanent
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Login User Error: $e');
      return false;
    }
  }

  static Future<bool> deleteAccount(String username) async {
    String url = '${getUrl()}/user';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'text/plain'},
        body: username,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Delete Account Error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getPermissions() async {
    String url = '${getUrl()}/permissions';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } catch (e) {
      print('Get Permissions Error: $e');
      return {};
    }
  }

  static Future<bool> logout() async {
    String url = '${getUrl()}/logout';

    try {
      final response = await http.post(Uri.parse(url));

      return response.statusCode == 200;
    } catch (e) {
      print('Logout Error: $e');
      return false;
    }
  }

  static Future<String?> resetPassword(String username, String email) async {
    final data = {
      'username': username,
      'email': email,
    };

    try {
      final response = await http.post(
        Uri.parse('${getUrl()}/resetPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      return response.statusCode == 200 ? null : response.body;
    } catch (e) {
      print('Reset Password Error: $e');
      return null;
    }
  }
}

void main() async {}
