import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';
import 'package:sport_meet/application/presentation/home/home_page.dart';
import 'package:sport_meet/profile/users_profile_screen.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  Map<String, dynamic> personalInformation = User.info;
  List<Map<String, dynamic>> pendingList = [];
  List<Map<String, dynamic>> filteredPendingFriends = [];
  List<Map<String, dynamic>> filteredFriends = [];

  @override
  void initState() {
    super.initState();
    getNotifications();
  }

  void getNotifications() async {
    if (personalInformation.isEmpty) {
      personalInformation = await User.getInfo();
    }

    String username = personalInformation['username'];
    pendingList = await User.getFriends(username);
    setState(() {
      filteredFriends = pendingList
          .map((friend) => {
                'title': 'Friend Request from ${friend['name']}',
                'subtitle': friend['username'],
                'status': friend['status'],
                'sender': friend['sender'],
                'time': DateTime.now().toString(),
              })
          .toList();

      filteredPendingFriends = filteredFriends
          .where((friend) =>
              (friend['status'] == 'PENDING' && friend['sender'] != username))
          .toList();
    });
  }

  void deleteNotification(int index) {
    setState(() {
      filteredPendingFriends.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.primary,
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Ionicons.notifications_outline,
                          size: 40,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notifications',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredPendingFriends.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(
                      filteredPendingFriends[index]['title'],
                      filteredPendingFriends[index]['subtitle'],
                      filteredPendingFriends[index]['time'],
                      filteredPendingFriends[index]['read'] ?? false,
                      () => acceptFriendRequest(context, index),
                      () => navigateToProfilePage(
                          context,
                          filteredPendingFriends[index]
                              ['subtitle']), // Navegar para o perfil
                      () => showDeleteConfirmation(context, index),
                      () => rejectFriendRequest(
                          context,
                          filteredPendingFriends[index][
                              'subtitle']), // Função para mostrar o diálogo de confirmação
                    );
                  },
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Ionicons.arrow_back_circle_outline,
                          color: Theme.of(context).colorScheme.onTertiary,
                          size: 30,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
      String title,
      String subtitle,
      String time,
      bool isRead,
      VoidCallback acceptFriend,
      VoidCallback navigateToProfile,
      VoidCallback deleteNotification,
      VoidCallback reject) {
    return GestureDetector(
      onTap: navigateToProfile,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Card(
          color: Theme.of(context).colorScheme.onPrimary,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'FredokaRegular',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isRead
                            ? Colors.grey
                            : Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Ionicons.checkmark_done_circle_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      onPressed: acceptFriend,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'FredokaRegular',
                    fontSize: 14,
                    color: isRead
                        ? Colors.grey
                        : Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(
                      Ionicons.trash_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    onPressed: reject,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  void navigateToProfilePage(BuildContext context, String profileUsername) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsersProfileScreen(
            ownUsername: personalInformation['username'],
            profileUsername:
                profileUsername),
      ),
    );
  }

  void showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content:
              const Text('Are you sure you want to delete this notification?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                deleteNotification(
                    index); // Chama a função para deletar notificação
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> acceptFriendRequest(BuildContext context, int index) async {
    if (personalInformation.isEmpty) {
      personalInformation = await User.getInfo();
    }

    String friendUsername = filteredPendingFriends[index]['subtitle'];
    bool success = await User.addFriend(friendUsername); // was acceptfriend before, i removed that method

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend Request Accepted'),
        ),
      );
      deleteNotification(index); // Remove notificação da lista após aceitar
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to Accept Friend Request'),
        ),
      );
    }
  }

  rejectFriendRequest(BuildContext context, friend) {
    User.removeFriend(friend);
  }
}
