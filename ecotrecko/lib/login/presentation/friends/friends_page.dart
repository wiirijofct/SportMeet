// ignore_for_file: constant_identifier_names

import 'dart:io' as io;

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecotrecko/login/application/user.dart';
import 'package:ecotrecko/profile/users_profile_screen.dart';
import 'package:ionicons/ionicons.dart';

const String PENDING = "PENDING";
const String ACCEPTED = "ACCEPTED";

String capitalize(String s) =>
    s[0].toUpperCase() + s.substring(1).toLowerCase();

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  dynamic _profileImage;
  Map<String, dynamic> personalInformation = User.info;
  Map<String, dynamic> usersInformation = User.info;
  List<Map<String, dynamic>> friendList = [];
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> filteredFriends = [];
  Map<String, Map<String, dynamic>> filteredUsers = {};
  Map<String, Map<String, dynamic>> users = {};
  TextEditingController addFriendController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getInfo();
    getInfoUsers();
    searchController.addListener(_filterFriends);
    addFriendController.addListener(_filterUsers); // Adicionei esta linha
  }

  void getInfo() async {
    if (personalInformation.isEmpty) {
      personalInformation = await User.getInfo();
    }

    String username = personalInformation['username'];
    friendList = await User.getFriends(username);
    setState(() {
      friends = friendList
          .map((friend) => {
                'username': friend['username'],
                'name': friend['name'],
                'status': friend['status'],
                'sender': friend['sender'],
                'avatarURL': friend['avatarURL'],
                'countryCode': friend['countryCode'],
              })
          .toList();

      filteredFriends = friends
          .where((friend) =>
              friend['status'] == ACCEPTED ||
              (friend['status'] == PENDING && friend['sender'] == username))
          .toList();
    });
  }

  void getInfoUsers() async {
    if (personalInformation.isEmpty) {
      personalInformation = await User.getInfo();
    }

    Map<String, dynamic> fetchedUsers = await User.getUserList();
    fetchedUsers.remove(personalInformation['username']);

    setState(() {
      users = fetchedUsers.map((username, userInfo) {
        return MapEntry(username, {
          'name': userInfo['name'],
        });
      });

      filteredUsers = users;
    });
  }

  void _filterFriends() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredFriends = friends.where((friend) {
        final username = friend['username'].toLowerCase();
        final ownUsername = personalInformation['username'];
        // return friend['status'] == ACCEPTED && name.contains(query);
        return username.contains(query) &&
                username != personalInformation['username'] &&
                friend['status'] == ACCEPTED ||
            (friend['status'] == PENDING && friend['sender'] == ownUsername);
      }).toList();
    });
  }

  void _filterUsers() {
    final query = addFriendController.text.toLowerCase();
    setState(() {
      filteredUsers = Map.fromEntries(
        users.entries.where((entry) => entry.key.toLowerCase().contains(query)),
      );
    });
  }

  AlertDialog removeFriend(String friendUsername) {
    return AlertDialog(
      title: Text(
        'Remove $friendUsername',
        style: Theme.of(context).textTheme.labelMedium,
      ),
      content: Text(
        'Are you sure you want to remove $friendUsername?',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (await User.removeFriend(friendUsername)) {
              Navigator.of(context).pop(true);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    title: const Text('Success'),
                    content: const Text('Friend removed successfully'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'OK',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onTertiary),
                        ),
                      ),
                    ],
                  );
                },
              );
              setState(() {
                friends.removeWhere(
                    (friend) => friend['username'] == friendUsername);
                _filterFriends();
              });
            } else {
              return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    title: const Text('Error'),
                    content: const Text('Failed to remove friend'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: Text(
            'Yes',
            style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(
            'No',
            style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.background,
                  Theme.of(context).colorScheme.primary,
                ],
              ),
            ),
          ),
          Column(
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
                          Ionicons.people_outline,
                          size: 40,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Friends',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          suffixIconColor:
                              Theme.of(context).colorScheme.onSecondary,
                          prefixIconColor:
                              Theme.of(context).colorScheme.onSecondary,
                          hintText: 'Search Friends',
                          hintStyle: TextStyle(
                            fontFamily: 'FredokaRegular',
                            color:
                                Theme.of(context).textTheme.labelSmall!.color,
                          ),
                          prefixIcon: Icon(
                            Ionicons.search_outline,
                            color:
                                Theme.of(context).textTheme.labelSmall!.color,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.onPrimary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 20,
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: 'FredokaRegular',
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredFriends.length,
                  itemBuilder: (context, index) {
                    return _buildFriendEntry(
                        filteredFriends[index]['username'],
                        filteredFriends[index]['name'],
                        filteredFriends[index]['status'],
                        filteredFriends[index]['countryCode'],
                        filteredFriends[index]['avatarURL'], () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return removeFriend(
                                filteredFriends[index]['username']);
                          });
                    });
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
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddFriendPage(
                        ownUsername: personalInformation['username'],
                        users: users),
                  ),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Icon(
                Ionicons.person_add_outline,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendEntry(String username, String name, String status,
      String countryCode, String avatarURL, VoidCallback removeCallback) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UsersProfileScreen(
                    ownUsername: personalInformation['username'],
                    profileUsername: username,
                  )),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
                radius: 30,
                backgroundImage: _profileImage != null
                    ? (kIsWeb
                        ? MemoryImage(_profileImage) as ImageProvider<Object>
                        : FileImage(_profileImage as io.File)
                            as ImageProvider<Object>)
                    : NetworkImage(avatarURL)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    status == PENDING
                        ? "\t\t\t$name (${capitalize(status)})"
                        : "\t\t\t$name",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'FredokaRegular',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                  Text(
                    "\t\t\t $username",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'FredokaRegular',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                  CountryCodePicker(
                    initialSelection: countryCode,
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 13,
                      fontFamily: "FredokaRegular",
                    ),
                    showCountryOnly: true,
                    showOnlyCountryWhenClosed: true,
                    alignLeft: false,
                    enabled: false, // Desabilitar a edição aqui
                  ),
                  // TODO LOCATION HERE
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    Ionicons.heart_dislike_outline,
                    size: 25,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                  onPressed: removeCallback,
                ),
                Text(
                  status == PENDING ? 'Cancel' : 'Remove',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontFamily: "FredokaRegular",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddFriendPage extends StatefulWidget {
  final Map<String, Map<String, dynamic>> users;
  final String ownUsername;

  const AddFriendPage(
      {super.key, required this.ownUsername, required this.users});

  @override
  _AddFriendPageState createState() => _AddFriendPageState(ownUsername);
}

class _AddFriendPageState extends State<AddFriendPage> {
  TextEditingController addFriendController = TextEditingController();
  Map<String, Map<String, dynamic>> filteredUsers = {};
  final String ownUsername;

  _AddFriendPageState(this.ownUsername);

  @override
  void initState() {
    super.initState();
    
    filteredUsers = widget.users;
    addFriendController.addListener(_filterUsers);
  }

  void _filterUsers() {
    final query = addFriendController.text.toLowerCase();
    setState(() {
      filteredUsers = Map.fromEntries(
        widget.users.entries.where(
          (entry) => entry.key.toLowerCase().contains(query),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: addFriendController,
              decoration: InputDecoration(
                hintText: 'Search by Username',
                hintStyle: TextStyle(
                  fontFamily: 'FredokaRegular',
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                prefixIcon: Icon(
                  Ionicons.search_outline,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
              ),
              style: TextStyle(
                fontFamily: 'FredokaRegular',
                fontSize: 18,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.keys.length,
                itemBuilder: (context, index) {
                  String username = filteredUsers.keys.elementAt(index);
                  String name = filteredUsers[username]!['name'].toString();
                  Map<String, dynamic>? userInfo = filteredUsers[username];

                  if (userInfo != null && userInfo.isNotEmpty) {
                    return _buildUserEntry(username, name);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserEntry(String username, String name) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UsersProfileScreen(
                    ownUsername: ownUsername,
                    profileUsername: username,
                  )),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'FredokaRegular',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                  Text(
                    username,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'FredokaRegular',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Ionicons.person_add_outline,
                color: Theme.of(context).colorScheme.onTertiary,
                size: 30,
              ),
              onPressed: () {
                addFriend(username);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addFriend(String username) async {
    bool success = await User.addFriend(username);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request sent to $username'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send friend request to $username'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
