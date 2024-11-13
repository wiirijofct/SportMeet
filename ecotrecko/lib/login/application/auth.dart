// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:ecotrecko/dio/http_service.dart';

class Authentication {
  static const int minPasswordLength = 8;

  static String getUrl() {
    if (!kIsWeb) {
      return "https://ecotrecko.nw.r.appspot.com/rest";
    }
    String url = "${html.window.location.href}rest";
    return url.contains("localhost") ? 'http://localhost:8080/rest' : url;
  }

  static HttpService httpService = HttpService();

  static bool isPasswordCompliant(String password) {
    if (password.isEmpty) {
      return false;
    }

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
    if (email.isEmpty) {
      return false;
    }

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

    print('Create User Data: $data'); // Debug print

    try {
      final dio = await httpService.createDio();
      final response = await dio.post(
        url,
        data: data,
        options: Options(
            headers: {'Content-Type': 'application/json'},
            followRedirects: true,
            validateStatus: (_) => true),
      );

      return response.statusCode == 200 ? null : response.data.toString();
    } on DioException catch (e) {
      print('Create User Error: ${e.type}');
      print(e.error);
      print(e.response);
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
        final image = MemoryImage(Uint8List.fromList(bytes));
        return image;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<String?> uploadImage(String username, Uint8List imgFile) async {
    String url = '${getUrl()}/user/uploadProfilePicture';

    try {
      final mimeType = 'image/png';

      print('Uploading image with MIME type: $mimeType'); // Debug print

      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['username'] = username
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            imgFile,
            filename: 'profile.png',
            contentType: MediaType.parse(mimeType),
          ),
        );

      print('Sending request to $url'); // Debug print

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        try {
          final responseBody = jsonDecode(response.body);
          print('Upload Image Response: $responseBody'); // Debug print

          if (responseBody is String) {
            return responseBody;
          } else if (responseBody is Map<String, dynamic> &&
              responseBody.containsKey('imageUrl')) {
            return responseBody['imageUrl'] as String?;
          } else {
            print('Unexpected response format: $responseBody');
            return null;
          }
        } catch (e) {
          return response.body;
        }
      } else {
        print('Upload Image Failed: ${response.statusCode}');
        return null;
      }
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

    print('Update User Profile Pic Data: $data'); // Debug print

    try {
      final dio = await httpService.createDio();
      final response = await dio.patch(
        url,
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
        ),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Update User Profile Pic Error: ${e.type}');
      print(e.error);
      print(e.message);
      return false;
    }
  }

  static Future<bool> loginUser(
      String username, String password, bool isPermanent) async {
    final data = {
      'username': username,
      'password': password,
      'isPermanent': isPermanent
    };
    String url = '${getUrl()}/login';
    try {
      final dio = await httpService.createDio();
      final response = await dio.post(
        url,
        data: data,
        options: Options(
            headers: {'Content-Type': 'application/json'},
            followRedirects: true,
            validateStatus: (_) => true),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.type);
      print(e.error);
      print(e.message);
      return false;
    }
  }

  static Future<bool> deleteAccount(String username) async {
    String url = '${getUrl()}/user';

    try {
      final dio = await httpService.createDio();
      final response = await dio.delete(
        url,
        data: username,
        options: Options(
          headers: {'Content-Type': 'text/plain'},
          followRedirects: true,
        ),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.message);
      return false;
    }
  }

  static Future<Map<String, dynamic>> getPermissions() async {
    String url = '${getUrl()}/permissions';

    try {
      final dio = await httpService.createDio();
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {};
      }
    } on DioException catch (e) {
      print(e.message);
      return {};
    }
  }

  static Future<Map<String, Map<String, dynamic>>> getGoals() async {
    String url = '${getUrl()}/goals';

    try {
      final dio = await httpService.createDio();
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final goals = (response.data as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value as Map<String, dynamic>));

        return goals;
      } else {
        return {};
      }
    } on DioException catch (e) {
      print(e.message);
      return {};
    }
  }

  static Future<bool> verifyToken() async {
    String url = '${getUrl()}/cookies/token';

    try {
      final dio = await httpService.createDio();
      final response = await dio.get(url);

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.message);
      return false;
    }
  }

  static Future<bool> logout() async {
    String url = '${getUrl()}/logout';

    try {
      final dio = await httpService.createDio();
      final response = await dio.post(url);

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.message);
      return false;
    }
  }

  static Future<String?> resetPassword(String username, String email) async {
    final data = {
      'username': username,
      'email': email,
    };

    String url = '${Authentication.getUrl()}/user/password/reset';
    try {
      final dio = await httpService.createDio();
      final response = await dio.post(
        url,
        data: data,
        options: Options(
            headers: {'Content-Type': 'application/json'},
            followRedirects: true,
            validateStatus: (_) => true),
      );

      return response.statusCode == 200 ? null : response.data.toString();
    } on DioException catch (e) {
      print(e.type);
      print(e.error);
      print(e.response);
      return null;
    }
  }
}

void main() async {}
