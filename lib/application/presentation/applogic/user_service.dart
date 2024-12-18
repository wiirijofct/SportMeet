import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';

class UserService {

  late Future<Map<String, dynamic>> userInfo;
  late String username;
  late String id;

  UserService() {
    userInfo = User.getInfo();
    userInfo.then((info) {
      username = info['username'];
      id = info['id'];
    });
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
  final response = await http.get(Uri.parse('http://localhost:3000/users'));
  if (response.statusCode == 200) {
    List<dynamic> users = json.decode(utf8.decode(response.bodyBytes));
    return users.where((user) => user['id'] != id).map((user) {
      return {
        'id': user['id'],
        'firstName': user['firstName'],
        'lastName': user['lastName'],
        'municipality': user['municipality'],
        'birthDate': user['birthDate'],
        'availability': List<String>.from(user['availability'] ?? []),
        'sports': List<String>.from(user['sports'] ?? []),
        'gender': user['gender'],
        'imagePath': user['imagePath'],
        'title': '${user['firstName']} ${user['lastName']}',
        'address': 'Municipality: ${user['municipality']}',
        'availabilityDisplay': user['availability'] != null ? 'Availability: ${List<String>.from(user['availability']).join(', ')}' : 'Availability: N/A',
        'sportsDisplay': user['sports'] != null ? 'Favorite Sports: ${List<String>.from(user['sports']).join(', ')}' : 'Favorite Sports: N/A',
        'genderDisplay': 'Gender: ${user['gender']}',
      };
    }).toList();
  } else {
    throw Exception('Failed to load users');
  }
}

  Future<void> addFriend(String friendId) async {
    print('Logged-in user ID: $id');
    print('Adding friend with ID: $friendId');

    // Fetch the current user data
    final response = await http.get(Uri.parse('http://localhost:3000/users/$id'));
    if (response.statusCode == 200) {
      final user = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> friends = user['friends'] ?? [];

      // Add the new friend ID to the friends list
      if (!friends.contains(friendId)) {
        friends.add(friendId);
      }

      // Update the user data with the new friends list
      final updateResponse = await http.put(
        Uri.parse('http://localhost:3000/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({...user, 'friends': friends}),
      );

      if (updateResponse.statusCode == 200) {
        // Update the logged-in user's friends list in shared preferences
        final loggedInUser = await User.getInfo();
        loggedInUser['friends'] = friends;
        await Authentication.saveLoggedInUser(loggedInUser);
        print('Logged-in user updated in SharedPreferences.');
      } else {
        throw Exception('Failed to update user data');
      }
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  Future<void> removeFriend(String friendId) async {
    print('Logged-in user ID: $id');
    print('Removing friend with ID: $friendId');

    // Fetch the current user data
    final response = await http.get(Uri.parse('http://localhost:3000/users/$id'));
    if (response.statusCode == 200) {
      final user = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> friends = user['friends'] ?? [];

      // Remove the friend ID from the friends list
      friends.remove(friendId);

      // Update the user data with the new friends list
      final updateResponse = await http.put(
        Uri.parse('http://localhost:3000/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({...user, 'friends': friends}),
      );

      if (updateResponse.statusCode == 200) {
        // Update the logged-in user's friends list in shared preferences
        final loggedInUser = await User.getInfo();
        loggedInUser['friends'] = friends;
        await Authentication.saveLoggedInUser(loggedInUser);
        print('Logged-in user updated in SharedPreferences.');
      } else {
        throw Exception('Failed to update user data');
      }
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  List<String> getUniqueSports(List<dynamic> users) {
    final sports = users
        .expand((user) => user['sports'] as List<dynamic>)
        .toSet()
        .map((sport) => sport.toString())
        .toList();
    sports.sort();
    return sports;
  }
}