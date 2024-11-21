import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sport_meet/application/presentation/fields/field_page.dart';
import 'package:sport_meet/application/presentation/home/home_page.dart';
import 'package:sport_meet/application/presentation/search/meet_page.dart';
import 'package:sport_meet/application/presentation/widgets/field_card.dart';
import 'dart:convert';
import 'package:sport_meet/application/presentation/fields/manage_fields_page.dart';
import 'package:sport_meet/application/presentation/fields/favorite_fields_page.dart';
import 'package:sport_meet/application/presentation/chat_page.dart';
import 'package:sport_meet/profile/profile_screen.dart';
import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<Map<String, dynamic>> userInfo;
  List<String> sportsFilters = [];
  List<String> selectedSports = [];
  List<String> selectedTeamAvailability = ['OPEN', 'CLOSED'];
  bool isFree = false;
  bool showOpenTeam = false;
  bool isHostUser = false;

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  TimeOfDay? selectedTime;

  final TextEditingController _searchController = TextEditingController();
  String selectedSortOption = ''; // Variable to hold the selected sort option
  List<dynamic> filteredEvent = []; // Class variable for filtered events
  List<dynamic> fieldData = []; // To hold field data from JSON
  List<dynamic> filteredFieldData = [];
  bool? isPublicFilter; // null = no preference, true = public, false = private

  @override
  void initState() {
    super.initState();
    Authentication.getUserSports().then((value) {
      setState(() {
        sportsFilters = value;
        selectedSports =
          List.from(sportsFilters); // Initially select all sports
        fetchUserData(); // Fetch user data after setting sports filters
        fetchFieldsData(); // Load the fields data from API
      });
    });
    //selectedSports = List.from(sportsFilters); // Initially select all sports
    //fetchFieldsData(); // Load the fields data from API
    //fetchUserData();
  }

  Future<void> fetchFieldsData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/fields'));
      if (response.statusCode == 200) {
        setState(() {
          fieldData = json.decode(response.body);
          filteredFieldData = fieldData;
        });
      } else {
        throw Exception('Failed to load fields');
      }
    } catch (e) {
      print('Error fetching fields data: $e');
    }
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

  @override
  void dispose() {
    // Dispose of the controller when the widget is removed
    _searchController.dispose();
    super.dispose();
  }

  void toggleSportFilter(String sport) {
    setState(() {
      if (selectedSports.contains(sport)) {
        selectedSports.remove(sport);
      } else {
        selectedSports.add(sport);
      }
    });
  }

  void _navigateToMeetPage() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const MeetPage(),
    ));
  }

  void resetFilters() {
    setState(() {
      selectedSports = List.from(sportsFilters); // Or an empty list if you want no selections
      isFree = false;
      showOpenTeam = false;
      selectedStartDate = null;
      selectedEndDate = null;
      selectedTime = null;
      selectedSortOption = ''; // Reset the sort option
      isPublicFilter = null; // Reset isPublic filter
      fetchFieldsData();
    });
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  
  void applyFilters() {
    setState(() {
      filteredFieldData = fieldData.where((field) {
        final sportsMatch = selectedSports.isEmpty || selectedSports.any((sport) => field['sport'].toString().toLowerCase().contains(sport));

        final isPublicMatch = isPublicFilter == null ||
            (field['isPublic'] != null && field['isPublic'] == isPublicFilter);

        final fieldOpenTime = _parseTime(field['schedule']['open']);
        final fieldCloseTime = _parseTime(field['schedule']['close']);

        final timeMatch = selectedTime == null ||
            (selectedTime!.hour >= fieldOpenTime.hour &&
            selectedTime!.hour < fieldCloseTime.hour);

        return sportsMatch && isPublicMatch && timeMatch;
      }).toList();
    });
  }


  // Method to count active filters
  int countActiveFilters() {
    int count = 0;

    // Count selected sports
    count += sportsFilters.length - selectedSports.length;

    // Count selected team availability
    count += 2 - selectedTeamAvailability.length;

    // Count date range filters
    if (selectedStartDate != null || selectedEndDate != null) {
      count += 1; // At least one date filter is applied
    }

    // Count time range filters
    if (selectedTime != null) {
      count += 1; // At least one time filter is applied
    }

    return count;
  }

   void showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Options'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                  // Sports Selection
                  const Text("Sports", style: TextStyle(fontSize: 18.0)),
                  ...sportsFilters.map((sport) {
                    return CheckboxListTile(
                      title: Text(sport),
                      value: selectedSports.contains(sport),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            selectedSports.add(sport);
                          } else {
                            selectedSports.remove(sport);
                          }
                        });
                      },
                    );
                  }).toList(),
                  const Text(
                    'Field Privacy',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<bool?>(
                    title: const Text('Public'),
                    value: true,
                    groupValue: isPublicFilter,
                    onChanged: (value) {
                      setState(() {
                        isPublicFilter = value;
                      });
                    },
                  ),
                  RadioListTile<bool?>(
                    title: const Text('Private'),
                    value: false,
                    groupValue: isPublicFilter,
                    onChanged: (value) {
                      setState(() {
                        isPublicFilter = value;
                      });
                    },
                  ),
                  RadioListTile<bool?>(
                    title: const Text('No Preference'),
                    value: null,
                    groupValue: isPublicFilter,
                    onChanged: (value) {
                      setState(() {
                        isPublicFilter = value;
                      });
                    },
                  ),
                  const Text(
                    'Time Filter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(selectedTime != null
                          ? '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                          : 'No time selected'),
                      IconButton(
                        icon: const Icon(Ionicons.time_outline),
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
              actions: [
                 TextButton(
                onPressed: () {
                  resetFilters(); // Reseta todos os filtros
                  Navigator.of(context).pop();
                },
                child: const Text('Clear Filters'),
                ),
                TextButton(
                  onPressed: () {
                    applyFilters(); // Aplica os filtros selecionados
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter the list based on searchQuery and showOpenTeam to match all text fields
      final filteredFieldData = fieldData.where((field) {
      final sport = field['sport'].toString().toLowerCase();
      final location = field['location'].toString().toLowerCase();
      final isPublic = field['isPublic'].toString().toLowerCase();
      final name = field['name'].toString().toLowerCase();
      final openTime = field['schedule']['open'].toString().toLowerCase();
      final closeTime = field['schedule']['close'].toString().toLowerCase();
      final query = _searchController.text.toLowerCase();

      // Check if any of the fields contain the search query
      final matchesSearchQuery = sport.contains(query) ||
            location.contains(query) ||
            isPublic.contains(query) ||
            name.contains(query) ||
            openTime.contains(query) ||
            closeTime.contains(query);
      
      final matchesSelectedSports = selectedSports.contains(field['sport']);
      final isPublicMatch = isPublicFilter == null ||
        (field['isPublic'] != null && field['isPublic'] == isPublicFilter);

      final fieldOpenTime = _parseTime(field['schedule']['open']);
      final fieldCloseTime = _parseTime(field['schedule']['close']);

      final timeMatch = selectedTime == null ||
          (selectedTime!.hour >= fieldOpenTime.hour &&
          selectedTime!.hour < fieldCloseTime.hour);

      return matchesSearchQuery && matchesSelectedSports && isPublicMatch && timeMatch;

    }).toList();

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Ionicons.search),
                      hintText: 'Search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      suffixIcon: IconButton(
                        icon: const Icon(Ionicons.close_circle, color: Colors.red), // Cross icon
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Ionicons.filter_outline),
                  onPressed: showFilterDialog,
                ),
                 // Badge for active filters
                  if (countActiveFilters() > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Center(
                          child: Text(
                            '${countActiveFilters()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sportsFilters.map((sport) {
                  bool isSelected = selectedSports.contains(sport);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(sport),
                      selected: isSelected,
                      onSelected: (_) => toggleSportFilter(sport),
                      selectedColor: Colors.brown,
                      backgroundColor: Colors.grey.shade300,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFieldData.length,
              itemBuilder: (context, index) {
                final field = filteredFieldData[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FieldPage(
                          fieldId: field['fieldId'],
                          fieldName: field['name'],
                          location: field['location'],
                          imagePath: field['images'][0],
                          schedule: '${field['schedule']['open']} - ${field['schedule']['close']}',
                          contactEmail: field['contact']['email'],
                          contactPhone: field['contact']['phone'],
                          pricing: field['isPublic'] ? 'Free' : field['pricing'],
                          // upcomingEvents: fieldData,
                          ),
                        ),
                    );
                  },
                  child: FieldCard(
                    sport: field['sport'],
                    name: field['name'],
                    location: field['location'],
                    openTime: field['schedule']['open'],
                    closeTime: field['schedule']['close'],
                    isPublic: field['isPublic'],
                    imagePath: field['images'][0],
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
            child: const Text('SEARCH'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _navigateToMeetPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade300,
              foregroundColor: Colors.white,
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
