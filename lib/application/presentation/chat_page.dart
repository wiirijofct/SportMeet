import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sport_meet/application/presentation/widgets/chat_card.dart';
import 'package:sport_meet/application/presentation/widgets/chat_details_page.dart';
import 'package:sport_meet/application/presentation/applogic/auth.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> chats = [];
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> chatCards = [];
  String? loggedInUserId;
  List<String> loggedInUserFriends = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
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
        List<dynamic> chatData = json.decode(chatResponse.body);
        List<dynamic> friendData = json.decode(friendResponse.body);

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

  void _navigateToChatDetail(Map<String, dynamic> chatCard) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(
          chatCard: chatCard,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
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
    );
  }
}