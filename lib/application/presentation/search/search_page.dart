import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sport_meet/application/presentation/widgets/event_card.dart';
import 'package:sport_meet/application/presentation/search/meet_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  List<String> sportsFilters = ['Basketball', 'Tennis', 'Swimming', 'Football'];
  List<String> selectedSports = [];
  List<String> selectedTeamAvailability = ['OPEN', 'CLOSED'];
  bool isFree = false;
  bool showOpenTeam = false;

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;


  final TextEditingController _searchController = TextEditingController();
  String selectedSortOption = ''; // Variable to hold the selected sort option
  List<Map<String, String>> filteredEvent = []; // Class variable for filtered events

  // Different people specific to the MeetPage
  final List<Map<String, String>> eventCards = [
    {
      'sport': 'Basketball',
      'date': '22.10.2024',
      'time': '10:00',
      'address': 'Avenida do Brasil',
      'field': 'Clube Unidos do Estoril',
      'availability': 'OPEN',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'sport': 'Football',
      'date': '22.10.2024',
      'time': '10:00',
      'address': 'Avenida Adamastor',
      'field': 'Clube Desunidos do Estoril',
      'availability': 'OPEN',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'sport': 'Football',
      'date': '22.11.2024',
      'time': '12:00',
      'address': 'Avenida Conceição Lopes',
      'field': 'Campo Bartolomeu',
      'availability': 'CLOSED',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'sport': 'Swimming',
      'date': '23.11.2024',
      'time': '21:00',
      'address': 'Rua Filo Lapa',
      'field': 'Piscinas Filo',
      'availability': 'OPEN',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'sport': 'Basketball',
      'date': '23.11.2024',
      'time': '22:00',
      'address': 'Avenida dos missionarios',
      'field': 'Campo António Sérgio',
      'availability': 'CLOSED',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'sport': 'Football',
      'date': '25.11.2024',
      'time': '19:00',
      'address': 'Rua Duarte Rei',
      'field': 'Escola Secundária Reitor Mor',
      'availability': 'OPEN',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'sport': 'Tennis',
      'date': '27.11.2024',
      'time': '15:00',
      'address': 'Avenida de baixo',
      'field': 'Campo De cima',
      'availability': 'OPEN',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'sport': 'Football',
      'date': '23.11.2024',
      'time': '15:00',
      'address': 'Avenida de cima',
      'field': 'Campo de baixo',
      'availability': 'CLOSED',
      'imagePath': 'lib/images/Gecko.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedSports = List.from(sportsFilters); // Initially select all sports
    filteredEvent = List.from(eventCards); // Initialize filteredEvent with all event cards
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
      selectedTeamAvailability = ['OPEN', 'CLOSED'];
      isFree = false;
      showOpenTeam = false;
      selectedStartDate = null;
      selectedEndDate = null;
      selectedStartTime = null;
      selectedEndTime = null;
      selectedSortOption = ''; // Reset the sort option
      filteredEvent = List.from(eventCards); // Reset filteredEvent to all events
    });
  }

  
  void applyFilters() {
  setState(() {
    // Filter the events based on the selected filters
    filteredEvent = eventCards.where((event) {
      final sportsMatch = selectedSports.isEmpty || selectedSports.any((sport) => event['sport']!.contains(sport));
      final matchesAvailability = selectedTeamAvailability.isEmpty || selectedTeamAvailability.any((availability) => event['availability']!.contains(availability));

      // Parse the event date
      DateTime eventDate = DateTime.parse(event['date']!.split('.').reversed.join('-')); // Convert to DateTime
      // Parse the event time
      TimeOfDay eventTime = TimeOfDay(
        hour: int.parse(event['time']!.split(':')[0]),
        minute: int.parse(event['time']!.split(':')[1]),
      );

      // Check if the event date is within the selected date range
      bool dateInRange = true;
      if (selectedStartDate != null && selectedEndDate != null) {
        // Both dates are selected
        dateInRange = eventDate.isAfter(selectedStartDate!.subtract(Duration(days: 1))) && eventDate.isBefore(selectedEndDate!.add(Duration(days: 1))); // Inclusive of end date
      } else if (selectedStartDate != null) {
        // Only start date is selected
        dateInRange = eventDate.isAfter(selectedStartDate!.subtract(Duration(days: 1))); // Inclusive of start date
      } else if (selectedEndDate != null) {
        // Only end date is selected
        dateInRange = eventDate.isBefore(selectedEndDate!.add(Duration(days: 1))) && eventDate.isAfter(DateTime.now().subtract(Duration(days: 1))); // Inclusive of end date
      }

      // Check if the event time is within the selected time range
      bool timeInRange = true;
      if (selectedStartTime != null && selectedEndTime != null) {
        timeInRange = (eventTime.hour > selectedStartTime!.hour || (eventTime.hour == selectedStartTime!.hour && eventTime.minute >= selectedStartTime!.minute)) &&
                      (eventTime.hour < selectedEndTime!.hour || (eventTime.hour == selectedEndTime!.hour && eventTime.minute <= selectedEndTime!.minute));
      } else if (selectedStartTime != null) {
        timeInRange = (eventTime.hour > selectedStartTime!.hour || (eventTime.hour == selectedStartTime!.hour && eventTime.minute >= selectedStartTime!.minute));
      } else if (selectedEndTime != null) {
        timeInRange = (eventTime.hour < selectedEndTime!.hour || (eventTime.hour == selectedEndTime!.hour && eventTime.minute <= selectedEndTime!.minute));
      }
      
      return sportsMatch && matchesAvailability && dateInRange && timeInRange;
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
    if (selectedStartTime != null || selectedEndTime != null) {
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

                  const SizedBox(height: 16.0),

                  // Team Availability Selection
                  const Text("Team Availability", style: TextStyle(fontSize: 18.0)),
                  ...['OPEN', 'CLOSED'].map((availability) {
                    return CheckboxListTile(
                      title: Text(availability),
                      value: selectedTeamAvailability.contains(availability),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            selectedTeamAvailability.add(availability);
                          } else {
                            selectedTeamAvailability.remove(availability);
                          }
                        });
                      },
                    );
                  }).toList(),
                  // Date Range Selection
                  const Text(
                    'Select Date Range',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedStartDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedStartDate = pickedDate;
                            });
                          }
                        },
                        child: Text(
                          selectedStartDate != null
                              ? 'From: ${selectedStartDate!.toLocal().toString().split(' ')[0]}'
                              : 'Select Start Date',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedEndDate ?? (selectedStartDate ?? DateTime.now()),
                            firstDate: selectedStartDate ?? DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedEndDate = pickedDate;
                            });
                          }
                        },
                        child: Text(
                          selectedEndDate != null
                              ? 'To: ${selectedEndDate!.toLocal().toString().split(' ')[0]}'
                              : 'Select End Date',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  const Text(
                    'Select Time Range',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedStartTime ?? TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedStartTime = pickedTime;
                            });
                          }
                        },
                        child: Text(
                          selectedStartTime != null
                              ? 'From: ${selectedStartTime!.format(context)}'
                              : 'Select Start Time',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedEndTime ?? TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedEndTime = pickedTime;
                            });
                          }
                        },
                        child: Text(
                          selectedEndTime != null
                              ? 'To: ${selectedEndTime!.format(context)}'
                              : 'Select End Time',
                          style: TextStyle(color: Colors.blue),
                        ),
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
    final filteredEvent = eventCards.where((event) {
      final sport = event['sport']!.toLowerCase();
      final address = event['address']!.toLowerCase();
      final availability = event['availability']!.toLowerCase();
      final field = event['field']!.toLowerCase();
      final time = event['time']!.toLowerCase();
      final date = event['date']!.toLowerCase();
      final query = _searchController.text.toLowerCase();

      // Check if any of the fields contain the search query
      final matchesSearchQuery = sport.contains(query) ||
            address.contains(query) ||
            availability.contains(query) ||
            time.contains(query) ||
            date.contains(query) ||
            field.contains(query);

      // Check if the sport title is in selected sports
      final matchesSelectedSports = selectedSports.contains(event['sport']);
      final matchesTeamAvailability = selectedTeamAvailability.contains(event['availability']);

      // Parse the event date
      DateTime eventDate = DateTime.parse(event['date']!.split('.').reversed.join('-')); // Convert to DateTime
      // Parse the event time
      TimeOfDay eventTime = TimeOfDay(
        hour: int.parse(event['time']!.split(':')[0]),
        minute: int.parse(event['time']!.split(':')[1]),
      );

      // Check if the event date is within the selected date range
      bool dateInRange = true;
      if (selectedStartDate != null && selectedEndDate != null) {
        // Both dates are selected
        dateInRange = eventDate.isAfter(selectedStartDate!) && eventDate.isBefore(selectedEndDate!.add(Duration(days: 1))); // Inclusive of end date
      } else if (selectedStartDate != null) {
        // Only start date is selected
        dateInRange = eventDate.isAfter(selectedStartDate!.subtract(Duration(days: 1))); // Inclusive of start date
      } else if (selectedEndDate != null) {
        // Only end date is selected
        dateInRange = eventDate.isBefore(selectedEndDate!.add(Duration(days: 1))) && eventDate.isAfter(DateTime.now()); // Inclusive of end date
      }

      // Check if the event time is within the selected time range
      bool timeInRange = true;
      if (selectedStartTime != null && selectedEndTime != null) {
        timeInRange = (eventTime.hour > selectedStartTime!.hour || (eventTime.hour == selectedStartTime!.hour && eventTime.minute >= selectedStartTime!.minute)) &&
                      (eventTime.hour < selectedEndTime!.hour || (eventTime.hour == selectedEndTime!.hour && eventTime.minute <= selectedEndTime!.minute));
      } else if (selectedStartTime != null) {
        timeInRange = (eventTime.hour > selectedStartTime!.hour || (eventTime.hour == selectedStartTime!.hour && eventTime.minute >= selectedStartTime!.minute));
      } else if (selectedEndTime != null) {
        timeInRange = (eventTime.hour < selectedEndTime!.hour || (eventTime.hour == selectedEndTime!.hour && eventTime.minute <= selectedEndTime!.minute));
      }

      // Include event if it matches search query, selected sports, and availability
      return matchesSearchQuery && matchesSelectedSports && matchesTeamAvailability && dateInRange && timeInRange;

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
              itemCount: filteredEvent.length,
              itemBuilder: (context, index) {
                final event = filteredEvent[index];
                return EventCard(
                  sport: event['sport']!,
                  address: event['address']!,
                  availability: event['availability']!,
                  field: event['field']!,
                  date: event['date']!,
                  time: event['time']!,
                  imagePath: event['imagePath']!,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
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
            icon: Icon(Ionicons.heart_outline),
            label: 'Favorites',
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
            Navigator.of(context).pop();
            // Navigator.of(context).pushReplacement(
            //   MaterialPageRoute(builder: (context) => const HomePage()),
            // );
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
