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

  int calculateAge(String birthDate) {
    final birthDateParts = birthDate.split('/');
    final birthDay = int.parse(birthDateParts[0]);
    final birthMonth = int.parse(birthDateParts[1]);
    final birthYear = int.parse(birthDateParts[2]);

    final today = DateTime.now();
    int age = today.year - birthYear;

    if (today.month < birthMonth || (today.month == birthMonth && today.day < birthDay)) {
      age--;
    }

    return age;
  }

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
            'Gender: ${person['gender']}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Municipality: ${person['municipality']}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Availability: ${(person['availability'] as List<String>).join(', ')}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Age: ${calculateAge(person['birthDate'])}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Favorite Sports: ${(person['sports'] as List<String>).join(', ')}',
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