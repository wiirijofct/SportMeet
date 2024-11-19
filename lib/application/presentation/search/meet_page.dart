import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_meet/application/presentation/applogic/user_service.dart';
import 'package:sport_meet/application/presentation/applogic/app_state.dart';
import 'package:sport_meet/application/presentation/widgets/filter_dialog.dart';
import 'package:sport_meet/application/presentation/widgets/person_details_dialog.dart';
import 'package:sport_meet/application/presentation/widgets/chat_dialog.dart';
import 'package:ionicons/ionicons.dart';
import 'search_page.dart';
import 'package:sport_meet/application/presentation/widgets/person_card.dart';

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
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
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
          availabilityOptions: appState.selectedAvailability,
          municipalities: appState.selectedMunicipality,
          genderOptions: ['Male', 'Female'], // Customize as needed
          selectedSports: appState.selectedSports,
          selectedAvailability: appState.selectedAvailability,
          selectedMunicipality: appState.selectedMunicipality,
          selectedGender: appState.selectedGender,
          onSportsChanged: (values) => appState.selectedSports = values,
          onAvailabilityChanged: (values) => appState.selectedAvailability = values,
          onMunicipalityChanged: (values) => appState.selectedMunicipality = values,
          onGenderChanged: (value) => appState.selectedGender = value ?? '',
          onClearFilters: appState.resetFilters,
          onApplyFilters: appState.applyFilters,
        );
      },
    );
  }

  void _showPersonDetails(BuildContext context, Map<String, dynamic> person) {
    showDialog(
      context: context,
      builder: (_) {
        return PersonDetailsDialog(
          person: person,
          onAddFriend: () {
            Navigator.pop(context);
            // Implement "Add Friend" logic here
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
      appBar: AppBar(
        title: const Text('Meet'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(),
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
                    availability: person['availability']!,
                    sports: person['sports']!,
                    imagePath: person['imagePath']!,
                    gender: person['gender']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
