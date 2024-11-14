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
  bool isFree = false;
  bool showOpenTeam = false;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  final TextEditingController _searchController = TextEditingController();

  // Different people specific to the MeetPage
  final List<Map<String, String>> eventCards = [
    {
      'title': 'Basketball',
      'date': 'Date: 22.10.2024',
      'time': '10:00',
      'address': 'Address: Avenida do Brasil',
      'field': 'Field: Clube Unidos do Estoril',
      'availability': 'Team Availability: OPEN',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'title': 'Football',
      'date': 'Date: 22.10.2024',
      'time': '10:00',
      'address': 'Address: Avenida Adamastor',
      'field': 'Field: Clube Desunidos do Estoril',
      'availability': 'Team Availability: OPEN',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'title': 'Football',
      'date': 'Date: 22.11.2024',
      'time': '12:00',
      'address': 'Address: Avenida Conceição Lopes',
      'field': 'Field: Campo Bartolomeu',
      'availability': 'Team Availability: CLOSED',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'title': 'Swimming',
      'date': 'Date: 23.11.2024',
      'time': '21:00',
      'address': 'Address: Rua Filo Lapa',
      'field': 'Field: Piscinas Filo',
      'availability': 'Team Availability: OPEN',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'title': 'Basketball',
      'date': 'Date: 23.11.2024',
      'time': '22:00',
      'address': 'Address: Avenida dos missionarios',
      'field': 'Field: Campo António Sérgio',
      'availability': 'Team Availability: CLOSED',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'title': 'Football',
      'date': 'Date: 25.11.2024',
      'time': '19:00',
      'address': 'Address: Rua Duarte Rei',
      'field': 'Field: Escola Secundária Reitor Mor',
      'availability': 'Team Availability: OPEN',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'title': 'Tennis',
      'date': 'Date: 27.11.2024',
      'time': '15:00',
      'address': 'Address: Avenida de baixo',
      'field': 'Field: Campo De cima',
      'availability': 'Team Availability: OPEN',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'title': 'Football',
      'date': 'Date: 23.11.2024',
      'time': '15:00',
      'address': 'Address: Avenida de cima',
      'field': 'Field: Campo de baixo',
      'availability': 'Team Availability: CLOSED',
      'imagePath': 'lib/images/Gecko.png',
    },
  ];


  @override
  void initState() {
    super.initState();
    selectedSports = List.from(sportsFilters); // Initially select all sports
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
      // Add any other filter resets here
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
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                      ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Sort by',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Date Range',
                          style: TextStyle(
                            fontSize: 20.0,
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

                          // Other filters, input fields, etc.
                        ],
                      ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hour Range',
                          style: TextStyle(
                            fontSize: 20.0,
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
                            fontSize: 20.0,
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
                            fontSize: 20.0,
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
                            fontSize: 20.0,
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
                            fontSize: 20.0,
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
    // Filter the list based on searchQuery to match all text fields
    final filteredEvent = eventCards.where((event) {
      final title = event['title']!.toLowerCase();
      final address = event['address']!.toLowerCase();
      final availability = event['availability']!.toLowerCase();
      final field = event['field']!.toLowerCase();
      final time = event['time']!.toLowerCase();
      final date = event['date']!.toLowerCase();
      final query = _searchController.text.toLowerCase();

      // Check if any of the fields contain the search query
      final matchesSearchQuery = title.contains(query) ||
            address.contains(query) ||
            availability.contains(query) ||
            time.contains(query) ||
            date.contains(query) ||
            field.contains(query);

    // Check if the sport title is in selected sports
    final matchesSelectedSports = selectedSports.contains(event['title']);

    // Include event if it matches both the search query and selected sports
    return matchesSearchQuery && matchesSelectedSports;

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
                          setState(() {
                            
                          });
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
            itemCount: filteredEvent.length,
            itemBuilder: (context, index) {
              final event = filteredEvent[index];
              return EventCard(
                title: event['title']!,
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
      /*title: const Text(
        'SEARCH',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),*/
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
