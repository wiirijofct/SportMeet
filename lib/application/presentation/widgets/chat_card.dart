import 'package:flutter/material.dart';

class ChatCard extends StatelessWidget {
  final String id;
  final String friendId;
  final String name;
  final String lastMessage;
  final String? timestamp;
  final VoidCallback onTap;

  const ChatCard({
    super.key,
    required this.id,
    required this.friendId,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(name[0]),
      ),
      title: Text(name),
      subtitle: Text(lastMessage),
      trailing: timestamp != null
          ? Text(
              timestamp!,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          : null,
      onTap: onTap,
    );
  }
}
