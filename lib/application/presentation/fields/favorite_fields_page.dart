import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';
import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';
import 'package:sport_meet/application/presentation/chat_page.dart';
import 'package:sport_meet/application/presentation/home/home_page.dart';
import 'package:sport_meet/application/presentation/search/search_page.dart';
import 'package:sport_meet/application/presentation/search/search_widgets/field_list.dart';
import 'package:sport_meet/profile/profile_screen.dart';

class FavoriteFieldsPage extends StatefulWidget {
  const FavoriteFieldsPage({Key? key}) : super(key: key);

  @override
  State<FavoriteFieldsPage> createState() => _FavoriteFieldsPageState();
}

class _FavoriteFieldsPageState extends State<FavoriteFieldsPage> {
  late Future<List<Map<String, dynamic>>> favoriteFieldsFuture;
  bool isHostUser = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    favoriteFieldsFuture = _loadFavoriteFields();
  }

  void fetchUserData() async {
    final userInfo = await User.getInfo();
    setState(() {
      isHostUser = userInfo['hostUser'] ?? false;
    });
  }

  Future<List<Map<String, dynamic>>> _loadFavoriteFields() async {
    try {
      final loggedInUser = await Authentication.getLoggedInUser();
      if (loggedInUser == null) {
        throw Exception('No logged-in user found');
      }

      final favFields = List<String>.from(loggedInUser['favFields']);
      if (favFields.isEmpty) {
        return [];
      }

      final response = await http.get(Uri.parse('http://localhost:3000/fields'));
      if (response.statusCode == 200) {
        List<dynamic> fieldData = json.decode(utf8.decode(response.bodyBytes));
        return fieldData
            .where((field) => favFields.contains(field['fieldId']))
            .toList()
            .cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load fields');
      }
    } catch (e) {
      print('Error loading favorite fields: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Favorite Fields'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: favoriteFieldsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading favorite fields'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No favorite fields found'));
          }

          final favoriteFields = snapshot.data!;

          return FieldList(filteredFieldData: favoriteFields);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Ionicons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.chatbubble_ellipses_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(isHostUser ? Ionicons.add : Ionicons.heart_outline),
            label: isHostUser ? 'Field' : 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: 3,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchPage(),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatPage(),
              ),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}