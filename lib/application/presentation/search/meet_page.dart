import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'search_page.dart';
import 'package:sport_meet/application/presentation/widgets/person_card.dart';

class MeetPage extends StatefulWidget {
  const MeetPage({super.key});

  @override
  State<MeetPage> createState() => _MeetPageState();
}

class _MeetPageState extends State<MeetPage> {
  bool isFree = false;
  bool showOpenTeam = false;
  String searchQuery = '';

  // Different people specific to the MeetPage
  final List<Map<String, String>> meetPeople = [
    {
      'title': 'Maria Inês Silva',
      'address': 'Municipality: Amadora',    
      'availability': 'Availability: All days',
      'sports': 'Favorite Sports: Basketball, Tennis',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'title': 'Mariana Coelho',
      'address': 'Municipality: Porto',
      'availability': 'Availability: All days',
      'sports': 'Favorite Sports: Football, Tennis, Voleyball, Handball',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'title': 'Rafael Santos',
      'address': 'Municipality: Sintra',
      'availability': 'Availability: Weekends',
      'sports': 'Favorite Sports: Boxing',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'title': 'Hugo Canelas',
      'address': 'Municipality: Sintra',
      'availability': 'Availability: Wednesdays, Fridays',
      'sports': 'Favorite Sports: Basketball',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'title': 'Joana Gonçalves',
      'address': 'Municipality: Faro',
      'availability': 'Availability: Tuesdays',
      'sports': 'Favorite Sports: Tennis',
      'imagePath': 'lib/images/Gecko.png'
    },
    {
      'title': 'Pedro Pequeno',
      'address': 'Municipality: Setúbal',
      'availability': 'Availability: All days',
      'sports': 'Favorite Sports: Handball, Football',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'title': 'Gonçalo Marques',
      'address': 'Municipality: Setúbal',
      'availability': 'Availability: Tuesdays, Fridays',
      'sports': 'Favorite Sports: Football',
      'imagePath': 'lib/images/Gecko.png',
    },
    {
      'title': 'Inês Bartolo',
      'address': 'Municipality: Sintra',
      'availability': 'Availability: All days',
      'sports': 'Favorite Sports: Basketball',
      'imagePath': 'lib/images/Gecko.png',
    },
  ];

  void _navigateToSearchPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
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
                    const Text('Sort By'),
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
                    const Text('Date'),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Select Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Hour Range'),
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
                      const Text('Price Range'),
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
                    const Text('Maximum Distance'),
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
                        const Text('Show Open Teams'),
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
                        const Text('Free'),
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
    // Filter the list based on searchQuery to match all text fields
    final filteredPeople = meetPeople.where((person) {
      final title = person['title']!.toLowerCase();
      final address = person['address']!.toLowerCase();
      final availability = person['availability']!.toLowerCase();
      final sports = person['sports']!.toLowerCase();
      final query = searchQuery.toLowerCase();

      // Check if any of the fields contain the search query
      return title.contains(query) ||
            address.contains(query) ||
            availability.contains(query) ||
            sports.contains(query);
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
                        onChanged: (value) {
                        searchQuery = value; 
                      },
                      onSubmitted: (value) {
                      setState(() {
                        searchQuery = value;
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
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPeople.length,
              itemBuilder: (context, index) {
                final person = filteredPeople[index];
                return PersonCard(
                  title: person['title']!,
                  address: person['address']!,
                  availability: person['availability']!,
                  sports: person['sports']!,
                  imagePath: person['imagePath']!,
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
      automaticallyImplyLeading: false, // Remove the back arrow
      toolbarHeight: 70,
      centerTitle: true,
      backgroundColor: Colors.red,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
              // Stay on MeetPage
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
