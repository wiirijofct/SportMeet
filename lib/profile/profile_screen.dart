import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sport_meet/application/presentation/applogic/fields_service.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';
import 'package:sport_meet/application/presentation/chat_page.dart';
import 'package:sport_meet/application/presentation/fields/favorite_fields_page.dart';
import 'package:sport_meet/application/presentation/fields/manage_fields_page.dart';
import 'package:sport_meet/application/presentation/home/home_page.dart';
import 'package:sport_meet/application/presentation/search/search_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  dynamic _profileImage;
  bool _editing = false;
  bool isHostUser = false;

  Map<String, dynamic> personalInformation = User.info;
  Map<String, TextEditingController> controllers = {};
  int? _friendCount;
  List<String> favoriteSports = [];
  final TextEditingController _sportController = TextEditingController();
  late List<String> sportsOptions = [];
  final FieldsService _fieldsService = FieldsService();


  @override
  void initState() {
    super.initState();
    getInfo();
    _fetchAvailableSports();
  }

  Future<void> getInfo() async {
    if (personalInformation.isEmpty) {
      personalInformation = await User.getInfo();
    }

    personalInformation.forEach((key, value) {
      controllers[key] = TextEditingController(text: value.toString());
    });

    List<Map<String, dynamic>> friends =
        await User.getFriends(personalInformation['username']);
    setState(() {
      _friendCount = friends.length;
      favoriteSports = List<String>.from(personalInformation['sports'] ?? []);
    });

    isHostUser = personalInformation['isHostUser'] ?? false;
  }

  Future<void> _fetchAvailableSports() async {
    try {
      final sports = await _fieldsService.fetchAvailableSports();
      setState(() {
        sportsOptions = List<String>.from(sports);
      });
    } catch (e) {
      print('Error fetching available sports: $e');
    }
  }

  void _addSport(String sport) {
    setState(() {
      favoriteSports.add(sport);
    });
  }

  void _removeSport(String sport) {
    setState(() {
      favoriteSports.remove(sport);
    });
  }

  @override
  Widget build(BuildContext context) {
    String avatarURL = personalInformation['imagePath'] ?? '';
    String uniqueAvatarURL =
        '$avatarURL?${DateTime.now().millisecondsSinceEpoch}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImage != null
                            ? MemoryImage(_profileImage)
                            : NetworkImage(uniqueAvatarURL) as ImageProvider,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        personalInformation['username'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 8),
                          Text(
                            'Friends: ${_friendCount ?? 0}',
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Editable Information Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Information',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildEditableField('First Name', 'firstName', Ionicons.person_outline),
                      _buildEditableField('Last Name', 'lastName', Ionicons.person_outline),
                      _buildEditableField('Gender', 'gender', Ionicons.person_outline),
                      _buildEditableField('Municipality', 'municipality', Ionicons.location_outline),
                      _buildEditableField('Email', 'email', Ionicons.mail_outline),
                      _buildEditableField('Phone Number', 'phone', Ionicons.call_outline),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

                // Favorite Sports Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Favorite Sports',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: favoriteSports.map((sport) {
                          return Chip(
                            label: Text(sport),
                            onDeleted: () => _removeSport(sport),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      SportInput(
                        controller: _sportController,
                        sportsOptions: sportsOptions,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            _addSport(value);
                            _sportController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Center(
                child: ElevatedButton.icon(
                  onPressed: _editing
                      ? _saveProfile
                      : () => setState(() {
                            _editing = true;
                          }),
                  icon: Icon(
                      _editing ? Ionicons.save_outline : Ionicons.create_outline),
                  label: Text(_editing ? 'Save' : 'Edit'),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        currentIndex: 4,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatPage(),
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
          } else if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEditableField(String label, String key, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controllers[key],
                  readOnly: !_editing,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(125, 238, 238, 238),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    // Save profile logic here
    setState(() {
      _editing = false;
    });
  }
}

class SportInput extends StatelessWidget {
  final TextEditingController controller;
  final List<String> sportsOptions;
  final void Function(String) onSubmitted;

  const SportInput({
    Key? key,
    required this.controller,
    required this.sportsOptions,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return sportsOptions.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        onSubmitted(selection);
      },
      fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
        return TextField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          decoration: InputDecoration(
            labelText: 'Add a sport',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onSubmitted: (value) {
            onSubmitted(value);
            fieldTextEditingController.clear();
          },
        );
      },
    );
  }
}