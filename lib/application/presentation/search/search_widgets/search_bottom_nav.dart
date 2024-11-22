import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SearchBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isHostUser;

  SearchBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    required this.isHostUser,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
      currentIndex: currentIndex,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
    );
  }
}