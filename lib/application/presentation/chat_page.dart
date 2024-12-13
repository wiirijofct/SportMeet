import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sport_meet/application/presentation/search/search_page.dart';
import 'package:sport_meet/application/presentation/widgets/chat_card.dart';
import 'package:sport_meet/application/presentation/widgets/chat_details_page.dart';
import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:sport_meet/application/presentation/fields/manage_fields_page.dart';
import 'package:sport_meet/application/presentation/fields/favorite_fields_page.dart';
import 'package:sport_meet/profile/profile_screen.dart';
import 'package:sport_meet/application/presentation/home/home_page.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Future<Map<String, dynamic>> userInfo;
  List<Map<String, dynamic>> chats = [];
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> chatCards = [];
  String? loggedInUserId;
  List<String> loggedInUserFriends = [];
  bool isHostUser = false;

  @override
  void initState() {
    super.initState();
    Authentication.getUserSports().then((value) {
      setState(() {
        fetchUserData(); // Fetch user data after setting sports filters
      });
    });
    _loadChats();
  }

  void fetchUserData() {
    userInfo = User.getInfo();
    userInfo.then((value) {
      setState(() {
        isHostUser = value['hostUser'] ?? false;
      });
    });
    //userEvents = Authentication.getUserFilteredCompleteEvents(selectedSports);
  }

  Future<void> _loadChats() async {
    try {
      // Get logged-in user
      final loggedInUser = await Authentication.getLoggedInUser();
      if (loggedInUser == null) {
        throw Exception('No logged-in user found');
      }
      loggedInUserId = loggedInUser['id'];
      loggedInUserFriends = List<String>.from(loggedInUser['friends']);

      // Fetch chats
      final chatResponse = await http.get(Uri.parse('http://localhost:3000/chats'));
      final friendResponse = await http.get(Uri.parse('http://localhost:3000/users'));

      if (chatResponse.statusCode == 200 && friendResponse.statusCode == 200) {
        List<dynamic> chatData = json.decode(utf8.decode(chatResponse.bodyBytes));
        List<dynamic> friendData = json.decode(utf8.decode(friendResponse.bodyBytes));

        setState(() {
          chats = chatData
              .where((chat) => chat['users'].contains(loggedInUserId))
              .toList()
              .cast<Map<String, dynamic>>();

          friends = friendData
              .where((user) => loggedInUserFriends.contains(user['id']))
              .toList()
              .cast<Map<String, dynamic>>();

          _prepareChatCards();
        });
      }
    } catch (e) {
      print('Error loading chats or friends: $e');
    }
  }

  void _prepareChatCards() {
    // Add existing chats to the top
    List<Map<String, dynamic>> sortedChats = chats.map((chat) {
      String otherUserId = chat['users']
          .firstWhere((id) => id != loggedInUserId);
      Map<String, dynamic> otherUser = friends.firstWhere(
        (friend) => friend['id'] == otherUserId,
        orElse: () => {},
      );
      Map<String, dynamic> lastMessage = chat['messages'].last;

      return {
        'id': chat['id'],
        'userId': otherUserId,
        'name': '${otherUser['firstName']} ${otherUser['lastName']}',
        'lastMessage': lastMessage['message'],
        'timestamp': lastMessage['timestamp'],
      };
    }).toList();

    // Add friends without chat history
    List<Map<String, dynamic>> friendChats = friends.where((friend) {
      return !chats.any((chat) => chat['users'].contains(friend['id']));
    }).map((friend) {
      return {
        'id': "null",
        'userId': friend['id'],
        'name': '${friend['firstName']} ${friend['lastName']}',
        'lastMessage': 'Say hey!',
        'timestamp': null,
      };
    }).toList();

    setState(() {
      chatCards = [...sortedChats, ...friendChats];
    });
  }

  void _navigateToChatDetail(Map<String, dynamic> chatCard) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(
          chatCard: chatCard,
        ),
      ),
    );
    // Refresh the chat list when returning from ChatDetailPage
    _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Chats'),
        centerTitle: true,
      ),
      body: chatCards.isEmpty
          ? Center(
              child: Text(
                "You don't have any active chats, try adding some friends and come back.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 46, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: chatCards.length,
              itemBuilder: (context, index) {
                final chatCard = chatCards[index];
                return ChatCard(
                  id: chatCard['id'],
                  friendId: chatCard['userId'],
                  name: chatCard['name'],
                  lastMessage: chatCard['lastMessage'],
                  timestamp: chatCard['timestamp'],
                  onTap: () => _navigateToChatDetail(chatCard),
                );
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
        currentIndex: 1,
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
          } else if (index == 3) {
            if (isHostUser) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageFieldsPage(),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoriteFieldsPage(),
                ),
              );
            }
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