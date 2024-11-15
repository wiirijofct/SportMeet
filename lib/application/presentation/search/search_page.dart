import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sport_meet/application/presentation/widgets/event_card.dart';
import 'package:sport_meet/application/presentation/search/meet_page.dart';
import 'package:sport_meet/application/presentation/field_page.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sport_meet/application/presentation/widgets/field_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> sportsFilters = ['Basketball', 'Tennis', 'Swimming', 'Football'];
  List<String> selectedSports = [];
  bool isFree = false;
  bool showOpenTeam = false;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  final TextEditingController _searchController = TextEditingController();
  String selectedSortOption = ''; // Variable to hold the selected sort option
  List<Map<String, String>> filteredEvent = []; // Class variable for filtered events
  List<dynamic> fieldData = []; // To hold field data from JSON

  @override
  void initState() {
    super.initState();
    selectedSports = List.from(sportsFilters); // Initially select all sports
    loadFieldsData(); // Load the fields data from JSON
  }

  Future<void> loadFieldsData() async {
    final String response = await rootBundle.loadString('assets/data/fields.json');
    setState(() {
      fieldData = json.decode(response);
    });
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
      selectedSortOption = ''; // Reset the sort option
    });
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
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedSortOption.isEmpty ? null : selectedSortOption,
                      hint: const Text(
                        'Select sorting option',
                        style: TextStyle(color: Colors.black),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Sport', child: Text('Sport')),
                        DropdownMenuItem(value: 'Date', child: Text('Date')),
                        DropdownMenuItem(value: 'Time', child: Text('Time')),
                        DropdownMenuItem(value: 'Address', child: Text('Address')),
                        DropdownMenuItem(value: 'Field', child: Text('Field')),
                        DropdownMenuItem(value: 'Availability', child: Text('Availability')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSortOption = newValue ?? ''; // Update the selected sort option
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                      style: const TextStyle(color: Colors.black),
                      dropdownColor: Colors.lightGreenAccent[100],
                      iconEnabledColor: Colors.black,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Start Date Picker
                        TextButton(
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedStartDate ?? DateTime.now(),
                              firstDate: DateTime.now(), // Start from today
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedStartDate = pickedDate;
                                // Clear the end date if it no longer fits the range
                                if (selectedEndDate != null &&
                                    selectedEndDate!.isBefore(selectedStartDate!)) {
                                  selectedEndDate = null;
                                }
                              });
                            }
                          },
                          child: Text(
                            selectedStartDate != null
                                ? 'From: ${selectedStartDate!.toString().substring(0, 10)}'
                                : 'Select Start Date',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        // End Date Picker
                        TextButton(
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedEndDate ?? (selectedStartDate ?? DateTime.now()),
                              firstDate: selectedStartDate ?? DateTime.now(), // Start from selectedStartDate or today
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
                                ? 'To: ${selectedEndDate!.toString().substring(0, 10)}'
                                : 'Select End Date',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hour Range',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'From',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'To',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (!isFree) ...[
                      const Text(
                        'Price Range',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'From',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'To',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Text(
                      'Maximum Distance',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: '20',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Show Open Teams',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: showOpenTeam,
                          onChanged: (value) {
                            setState(() {
                              showOpenTeam = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Free',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: isFree,
                          onChanged: (value) {
                            setState(() {
                              isFree = value;
                            });
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
                    resetFilters(); 
                    Navigator.of(context).pop();
                  },
                  child: const Text('Reset', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (selectedSortOption.isNotEmpty) {
                        switch (selectedSortOption) {
                          case 'Sport':
                            fieldData.sort((a, b) => a['sport'].compareTo(b['sport']));
                            break;
                          case 'Date':
                            fieldData.sort((a, b) => a['date'].compareTo(b['date']));
                            break;
                          case 'Time':
                            fieldData.sort((a, b) => a['time'].compareTo(b['time']));
                            break;
                          case 'Address':
                            fieldData.sort((a, b) => a['location'].compareTo(b['location']));
                            break;
                          case 'Field':
                            fieldData.sort((a, b) => a['name'].compareTo(b['name']));
                            break;
                          case 'Availability':
                            fieldData.sort((a, b) => a['availability'].compareTo(b['availability']));
                            break;
                        }
                      }
                      Navigator.of(context).pop(); 
                    });
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
              itemCount: fieldData.length,
              itemBuilder: (context, index) {
                final field = fieldData[index];
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
                    // schedule: '${field['schedule']['open']} - ${field['schedule']['close']}',
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
