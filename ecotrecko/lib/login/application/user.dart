// ignore_for_file: avoid_print

import 'dart:io' as io;
import 'dart:typed_data';

import 'package:ecotrecko/login/application/auth.dart';
import 'package:dio/dio.dart';
import 'package:ecotrecko/dio/http_service.dart';
import 'package:path/path.dart';

void main() async {}

class User {
  static HttpService httpService = HttpService();
  // static final dio = httpService.createDio();

  // variable to store user info without needing to fetch it again
  static Map<String, dynamic> info = {};

  static Future<Map<String, dynamic>> getInfo() async {
    String url = '${Authentication.getUrl()}/user/info';
    try {
      final dio = await httpService.createDio();
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        info = response.data;

        return info;
      } else {
        print(response.statusCode);
        return {};
      }
    } on DioException catch (e) {
      print(e.message);
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getGlobalRankings() async {
    String url = '${Authentication.getUrl()}/users/leaderboard';
    try {
      final dio = await httpService.createDio();
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final rankings = List<Map<String, dynamic>>.from(response.data);

        rankings.sort((a, b) => b['points'].compareTo(a['points']));

        return rankings;
      } else {
        print(response.statusCode);
        return [];
      }
    } on DioException catch (e) {
      print(e.message);
      return [];
    }
  }

  static Future<Map<String, Map<String, dynamic>>> getGoalsProgress(
      String username) async {
    String url = '${Authentication.getUrl()}/user/goals';
    try {
      final dio = await httpService.createDio();
      final response = await dio.get(
        url,
        queryParameters: {"username": username},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
        ),
      );

      if (response.statusCode == 200) {
        final goals = (response.data as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value as Map<String, dynamic>));

        return goals;
      } else {
        print(response.statusCode);
        return {};
      }
    } on DioException catch (e) {
      print(e.message);
      return {};
    }
  }

  static Future<Map<String, dynamic>> getProfileInfo(String username) async {
    String url = '${Authentication.getUrl()}/user/profile';
    try {
      final dio = await httpService.createDio();
      final response = await dio.get(
        url,
        queryParameters: {"username": username},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print(response.statusCode);
        return {};
      }
    } on DioException catch (e) {
      print(e.message);
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getFriends(String username) async {
    String url = '${Authentication.getUrl()}/friends/list';
    try {
      final dio = await httpService.createDio();
      final response = await dio.get(
        url,
        queryParameters: {"username": username},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
        ),
      );

      if (response.statusCode == 200) {
        final friends = (response.data as List<dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList();

        return friends;
      } else {
        print(response.statusCode);
        return [];
      }
    } on DioException catch (e) {
      print(e.message);
      return [];
    }
  }

  static Future<Map<String, Map<String, dynamic>>> getUserList() async {
    String url = '${Authentication.getUrl()}/users';
    try {
      final dio = await httpService.createDio();
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final users = (response.data as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value as Map<String, dynamic>));

        return users;
      } else {
        print(response.statusCode);
        return {};
      }
    } on DioException catch (e) {
      print(e.message);
      return {};
    }
  }

  static Future<Map<String, Map<String, dynamic>>> getUserListMgmt() async {
    String url = '${Authentication.getUrl()}/users/mgmt';
    try {
      final dio = await httpService.createDio();
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final users = (response.data as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value as Map<String, dynamic>));

        return users;
      } else {
        print(response.statusCode);
        return {};
      }
    } on DioException catch (e) {
      print(e.message);
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getRankInfo(String username) async {
    List<Map<String, dynamic>> friends = await getFriends(username);
    List<String>? friendUsernames =
        friends.map((friend) => friend['username']).cast<String>().toList();

    if (friendUsernames.isEmpty) {
      return [];
    }

    String url = '${Authentication.getUrl()}/user/rankInfo';
    try {
      final dio = await httpService.createDio();
      final response = await dio.post(
        url,
        data: friendUsernames,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
        ),
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> rankInfo = (response.data as List<dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList();

        // Sort by points
        rankInfo.sort((a, b) => b['points'].compareTo(a['points']));

        return rankInfo;
      } else {
        print(response.statusCode);
        return [];
      }
    } on DioException catch (e) {
      print(e.message);
      return [];
    }
  }

  static Future<List<dynamic>> getUserCookie() async {
    String url = '${Authentication.getUrl()}/fetch/cookie';
    try {
      final dio = await httpService.createDio();
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final cookie = (response.data as List<dynamic>)
            .map((item) => item.toString())
            .toList();

        // print(response.headers);
        return cookie;
      } else {
        print(response.statusCode);
        return [];
      }
    } on DioException catch (e) {
      print(e.message);
      return [];
    }
  }

  static Future<bool> removeFriend(String friend) async {
    String url = '${Authentication.getUrl()}/friends/remove';
    try {
      final dio = await httpService.createDio();
      final response = await dio.post(
        url,
        queryParameters: {"username": friend},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(response.statusCode);
        return false;
      }
    } on DioException catch (e) {
      print(e.message);
      print(e.type);
      print(e.error);
      return false;
    }
  }

  static Future<bool> addFriend(String friend) async {
    String url = '${Authentication.getUrl()}/friends/add';
    try {
      final dio = await httpService.createDio();
      final response = await dio.post(
        url,
        queryParameters: {"username": friend},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(response.statusCode);
        return false;
      }
    } on DioException catch (e) {
      print(e.message);
      print(e.type);
      print(e.error);
      return false;
    }
  }

  static Future<bool> acceptFriend(String friend) async {
    String url = '${Authentication.getUrl()}/friends/accept';
    try {
      final dio = await httpService.createDio();
      final response = await dio.post(
        url,
        queryParameters: {"username": friend},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(response.statusCode);
        return false;
      }
    } on DioException catch (e) {
      print(e.message);
      print(e.type);
      print(e.error);
      return false;
    }
  }

  static Future<bool> addScore(String username, int points) async {
    String url = '${Authentication.getUrl()}/user/score';
    try {
      final dio = await httpService.createDio();
      final response = await dio.patch(
        url,
        queryParameters: {"username": username, "points": points},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(response.statusCode);
        return false;
      }
    } on DioException catch (e) {
      print(e.message);
      print(e.type);
      print(e.error);
      return false;
    }
  }

  static Future<bool> updateGoals(
      String username, String goalId, Map<String, dynamic> goals) async {
    String url = '${Authentication.getUrl()}/user/goals';

    try {
      final dio = await httpService.createDio();
      final response = await dio.patch(
        url,
        data: goals,
        queryParameters: {"username": username, "goalId": goalId},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
        ),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.message);
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
      print(e.message);
      return false;
    }
  }

  static Future<bool> uploadProfilePicture(dynamic file) async {
    String url = '${Authentication.getUrl()}/user/uploadProfilePicture';
    FormData formData;

    if (file is Uint8List) {
      formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(file, filename: 'profile.png'),
        "username": info['username'],
      });
    } else if (file is io.File) {
      formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path,
            filename: basename(file.path)),
        "username": info['username'],
      });
    } else {
      return false;
    }

    try {
      final dio = await httpService.createDio();
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200) {
        info['avatarURL'] = response.data['avatarURL'];
        return true;
      } else {
        print('Failed to upload. Status code: ${response.statusCode}');
        print('Response data: ${response.data}');
      }
    } on DioException catch (e) {
      print('DioError: ${e.message}');
      print('DioError type: ${e.type}');
      if (e.response != null) {
        print('DioError response data: ${e.response?.data}');
      }
      print('DioError stack trace: ${e.stackTrace}');
    } catch (e) {
      print('Unexpected error: $e');
    }

    return false;
  }

  static Future<bool> updatePermissions(String username, int permCode) async {
    String url = '${Authentication.getUrl()}/user/permissions';

    final data = {"username": username, "permissionCode": permCode};

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
      print(e.message);
      print(e.type);
      print(e.stackTrace);
      return false;
    }
  }

  static Future<bool> updateRole(String username, int roleCode) async {
    String url = '${Authentication.getUrl()}/user/role';

    final data = {"username": username, "newRole": roleCode};

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
      print(e.message);
      print(e.type);
      print(e.stackTrace);
      return false;
    }
  }

  static Future<bool> ban(
      String username, int until, String banType, String reason) async {
    String url = '${Authentication.getUrl()}/user/ban';

    final data = {
      "username": username,
      "until_us": until,
      "ban_type": banType,
      "ban_reason": reason,
    };

    try {
      final dio = await httpService.createDio();
      final response = await dio.post(
        url,
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
        ),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.message);
      return false;
    }
  }

  static Future<bool> unban(String username) async {
    String url = '${Authentication.getUrl()}/user/unban';

    try {
      final dio = await httpService.createDio();
      final response = await dio.delete(
        url,
        data: username,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
        ),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.message);
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getLogs(String username) async {
    String url = '${Authentication.getUrl()}/user/logs';

    try {
      final dio = await httpService.createDio();
      final response = await dio.get(
        url,
        queryParameters: {"username": username},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
        ),
      );

      if (response.statusCode == 200) {
        final logs = (response.data as List<dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList();

        logs.sort(
            (a, b) => b['time']['seconds'].compareTo(a['time']['seconds']));

        return logs;
      } else {
        return [];
      }
    } on DioException catch (e) {
      print(e.message);
      return [];
    }
  }

  static Future<void> calculateDailyEmissions() async {
    String username = info['username'];
    print("Username: $username");
    String url =
        '${Authentication.getUrl()}/emissions/calculateDaily?username=$username'; // Updated URL
    try {
      final dio = await httpService.createDio();
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        print("Emissions calculated successfully");
      } else {
        print("Failed to calculate daily emissions: ${response.statusCode}");
        print("Response body: ${response.data}");
      }
    } on DioException catch (e) {
      print("DioException caught: ${e.message}");
      print("Response data: ${e.response?.data}");
    } catch (e) {
      print("General exception caught: ${e.toString()}");
    }
  }

  static Future<dynamic> fetchDailyEmissions() async {
    String username = info['username'];
    print("Username: $username");
    String url =
        '${Authentication.getUrl()}/emissions/getDaily?username=$username'; // Updated URL
    try {
      final dio = await httpService.createDio();
      final response = await dio.get(url);

      print("Status code: ${response.statusCode}");
      print("Response data type: ${response.data.runtimeType}");
      print("Response data: ${response.data}");

      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData != null && responseData is Map<String, dynamic>) {
          info['totalEmission'] = responseData['totalEmission'];
          print("Total Emission: ${info['totalEmission']}");
        }
        return response.data;
      } else {
        print("Failed to fetch daily emissions: ${response.statusCode}");
        print("Response body: ${response.data}");
      }
    } on DioException catch (e) {
      print("DioException caught: ${e.message}");
      print("Response data: ${e.response?.data}");
    } catch (e) {
      print("General exception caught: ${e.toString()}");
    }
  }

  static Future<Map<int, double>?> fetchLastSevenEmissions() async {
    String? username = info['username'];
    if (username == null || username.isEmpty) {
      print("Invalid username provided for last 7 days of emissions retrieval");
      return null;
    }
    print("Username: $username");
    String url =
        '${Authentication.getUrl()}/emissions/getLastSeven?username=$username';
    try {
      final dio = await httpService.createDio();
      final response = await dio.get(url);

      print("Status code: ${response.statusCode}");
      print("Response data type: ${response.data.runtimeType}");
      print("Response data: ${response.data}");

      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData != null && responseData is Map) {
          Map<int, double> lastSevenDaysEmissions = {};
          responseData.forEach((key, value) {
            if (value is double) {
              lastSevenDaysEmissions[int.parse(key)] = value;
            }
          });
          print("Last Seven Days Emissions: $lastSevenDaysEmissions");
          return lastSevenDaysEmissions;
        }
      } else {
        print(
            "Failed to fetch last seven days emissions: ${response.statusCode}");
        print("Response body: ${response.data}");
      }
    } on DioException catch (e) {
      print("DioException caught: ${e.message}");
      print("Response data: ${e.response?.data}");
    } catch (e) {
      print("General exception caught: ${e.toString()}");
    }
    return null;
  }

  static Future<bool> updatePassword(
      String oldPassword, String newPassword) async {
    final data = {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
    String url = '${Authentication.getUrl()}/user/password';
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

      if (response.statusCode == 200) {
        return true;
      } else {
        print(response.statusCode);
        return false;
      }
    } on DioException catch (e) {
      print(e.message);
      return false;
    }
  }

  static Future<bool> updateUserCarTransportEmissions(double emissions) async {
    String url =
        '${Authentication.getUrl()}/emissions/updateCarTransportEmissions';
    try {
      final dio = await httpService.createDio();
      final response = await dio.post(url,
          data: {'transportEmission': emissions},
          queryParameters: {"username": info["username"]});

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.message);
      return false;
    }
  }

  static Future<bool> updateUserTransportEmissions(double emissions) async {
    String url =
        '${Authentication.getUrl()}/emissions/updateTransportEmissions';
    try {
      final dio = await httpService.createDio();
      final response = await dio.post(url,
          data: {'transportEmission': emissions},
          queryParameters: {"username": info["username"]});

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.message);
      return false;
    }
  }
}
