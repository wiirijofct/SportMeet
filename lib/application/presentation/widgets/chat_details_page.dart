import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sport_meet/application/presentation/applogic/auth.dart';

class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> chatCard;

  const ChatDetailPage({super.key, required this.chatCard});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  String? loggedInUserId;

  @override
  void initState() {
    super.initState();
    if (widget.chatCard['id'] != "null") _loadMessages();
    _getLoggedInUserId();
  }

  Future<void> _getLoggedInUserId() async {
    final loggedInUser = await Authentication.getLoggedInUser();
    if (loggedInUser != null) {
      setState(() {
        loggedInUserId = loggedInUser['id'];
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/chats/${widget.chatCard['id']}'));

      if (response.statusCode == 200) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(json.decode(utf8.decode(response.bodyBytes))['messages']);
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> _sendMessage() async {
  if (_messageController.text.isEmpty || loggedInUserId == null) return;

  final newMessage = {
    'id': DateTime.now().millisecondsSinceEpoch.toString(),
    'sender': loggedInUserId,
    'message': _messageController.text,
    'timestamp': DateTime.now().toIso8601String(),
  };

  setState(() {
    messages.add(newMessage);
  });

  try {
    if (widget.chatCard['id'] == "null") {
      // Create a new chat entry
      final newChatId = '${loggedInUserId}+${widget.chatCard['userId']}';
      final newChat = {
        'id': newChatId,
        'users': [loggedInUserId, widget.chatCard['userId']],
        'messages': messages,
      };

      final response = await http.post(
        Uri.parse('http://localhost:3000/chats'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newChat),
      );

      if (response.statusCode == 201) {
        setState(() {
          widget.chatCard['id'] = newChatId;
        });
      } else {
        throw Exception('Failed to create new chat');
      }
    } else {
      // Update existing chat
      await http.patch(
        Uri.parse('http://localhost:3000/chats/${widget.chatCard['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'messages': messages}),
      );
    }
    _messageController.clear();
  } catch (e) {
    print('Error sending message: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatCard['name']),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMine = message['sender'] == loggedInUserId;
                return Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: isMine ? Colors.red[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message['message']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: const TextStyle(
                        color: Colors.black, // Sets the hint text color
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send,
                  color: Colors.black),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}