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


  @override
  void initState() {
    super.initState();
    selectedSports = List.from(sportsFilters); // Initially select all sports
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
                        fillColor: Colors.grey.shade200,
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
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Ionicons.search),
                      hintText: 'Search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
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
              itemCount: 5, // Placeholder for number of fields/events
              itemBuilder: (context, index) {
                if (selectedSports.contains('Basketball')) {
                  return EventCard(
                    title: 'Basketball',
                    date: 'Date: 22.10.2024',
                    time: '10:00',
                    address: 'Address: Avenida do Brasil',
                    field: 'Field: Clube Unidos do Estoril',
                    availability: 'Team Availability: OPEN',
                    imagePath: 'lib/images/Gecko.png',
                  );
                } else {
                  return Container();
                }
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
