import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_meet/application/presentation/applogic/user_service.dart';
import 'package:sport_meet/application/presentation/applogic/app_state_meet.dart';
import 'package:sport_meet/application/presentation/widgets/filter_dialog.dart';
import 'package:sport_meet/application/presentation/widgets/person_details_dialog.dart';
import 'package:sport_meet/application/presentation/widgets/chat_dialog.dart';
import 'package:ionicons/ionicons.dart';
import 'search_page.dart';
import 'package:sport_meet/application/presentation/widgets/person_card.dart';
import 'package:sport_meet/application/presentation/manage_fields_page.dart';
import 'package:sport_meet/application/presentation/favorite_fields_page.dart';
import 'package:sport_meet/application/presentation/chat_page.dart';
import 'package:sport_meet/profile/profile_screen.dart';
import 'package:sport_meet/application/presentation/home/home_page.dart';
import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';

class MeetPage extends StatelessWidget {
  const MeetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MeetPageBody(),
    );
  }
}

class MeetPageBody extends StatefulWidget {
  const MeetPageBody({super.key});

  @override
  State<MeetPageBody> createState() => _MeetPageBodyState();
}

class _MeetPageBodyState extends State<MeetPageBody> {
  late Future<Map<String, dynamic>> userInfo;
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  bool isHostUser = false;

  @override
  void initState() {
    super.initState();
    Authentication.getUserSports().then((value) {
      setState(() {
        fetchUserData(); // Fetch user data after setting sports filters
      });
    });
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _loadUsers() async {
  final appState = Provider.of<AppState>(context, listen: false);
  try {
    final users = await _userService.fetchUsers();
    appState.setMeetPeople(users);
  } catch (e) {
    print('Error loading users: $e');
  }
}

  void _showFilterDialog(BuildContext context) {
  final appState = Provider.of<AppState>(context, listen: false);

  showDialog(
    context: context,
    builder: (_) {
      return FilterDialog(
        sportsOptions: appState.sportsFilters,
        availabilityOptions: appState.availabilityFilters,
        municipalities: appState.municipalityFilters,
        genderOptions: ['Male', 'Female', 'Other'], // Customize as needed
        selectedSports: appState.selectedSports,
        selectedAvailability: appState.selectedAvailability,
        selectedMunicipality: appState.selectedMunicipality,
        selectedGender: appState.selectedGender,
        onSportsChanged: (values) {
          appState.selectedSports = values;
          appState.notifyListeners();
        },
        onAvailabilityChanged: (values) {
          appState.selectedAvailability = values;
          appState.notifyListeners();
        },
        onMunicipalityChanged: (values) {
          appState.selectedMunicipality = values;
          appState.notifyListeners();
        },
        onGenderChanged: (value) {
          appState.selectedGender = value ?? '';
          appState.notifyListeners();
        },
        onClearFilters: () {
          appState.resetFilters();
          Navigator.of(context).pop();
        },
        onApplyFilters: () {
          appState.applyFilters();
          Navigator.of(context).pop();
        },
      );
    },
  );
}

  void _navigateToSearchPage() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SearchPage(),
    ));
  }

  void _showPersonDetails(BuildContext context, Map<String, dynamic> person) {
    showDialog(
      context: context,
      builder: (_) {
        return PersonDetailsDialog(
          person: person,
          onAddFriend: () async {
            Navigator.pop(context);
            try {
              final friendId = person['id'];
              if (friendId != null) {
                await _userService.addFriend(friendId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Friend added successfully')),
                );
              } else {
                throw Exception('Invalid friend ID');
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add friend: $e')),
              );
              print('Failed to add friend: $e');
            }
          },
          onSendMessage: () {
            Navigator.pop(context);
            _showChatDialog(context, person);
          },
        );
      },
    );
  }

  void _showChatDialog(BuildContext context, Map<String, dynamic> person) {
    showDialog(
      context: context,
      builder: (_) {
        return ChatDialog(person: person);
      },
    );
  }

  @override
Widget build(BuildContext context) {
  final appState = Provider.of<AppState>(context);

  return Scaffold(
    appBar: _buildAppBar(),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      appState.filteredEvent = appState.meetPeople
                          .where((person) => person['title']!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search',
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: appState.filteredEvent.length,
            itemBuilder: (context, index) {
              final person = appState.filteredEvent[index];
              return GestureDetector(
                onTap: () => _showPersonDetails(context, person),
                child: PersonCard(
                  title: person['title']!,
                  address: person['address']!,
                  availability: person['availabilityDisplay']!,
                  sports: person['sportsDisplay']!,
                  imagePath: person['imagePath']!,
                  gender: person['genderDisplay']!,
                ),
              );
            },
          ),
        ),
      ],
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
        currentIndex: 0,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
              else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatPage(),
                ),
              );
            }
            
             else if (index == 3) {
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

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      centerTitle: true,
      backgroundColor: Colors.red,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Highlight the active button with different colors
          ElevatedButton(
            onPressed: _navigateToSearchPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: const Text('SEARCH'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              // Stay on SearchPage
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: const Text('MEET'),
          ),
        ],
      ),
    );
  }
}