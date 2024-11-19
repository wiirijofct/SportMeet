import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:3000/users'));
    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);
      return users.map((user) {
        return {
          'title': '${user['firstName']} ${user['lastName']}',
          'address': 'Municipality: ${user['municipality']}',
          'availability': 'Availability: ${user['availability'].join(', ')}',
          'sports': 'Favorite Sports: ${user['sports'].join(', ')}',
          'gender': 'Gender: ${user['gender']}',
          'imagePath': user['imagePath'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load users');
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