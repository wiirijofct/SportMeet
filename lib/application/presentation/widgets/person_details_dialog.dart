import 'package:flutter/material.dart';

class PersonDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> person;
  final VoidCallback onAddFriend;
  final VoidCallback onSendMessage;

  const PersonDetailsDialog({
    required this.person,
    required this.onAddFriend,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        person['title']!,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              person['imagePath']!,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            person['sports']!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onAddFriend,
                child: const Text('Adicionar Amigo'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onSendMessage,
                child: const Text('Enviar Mensagem'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}