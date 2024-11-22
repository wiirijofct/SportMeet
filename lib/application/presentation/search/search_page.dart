import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sport_meet/application/presentation/fields/field_page.dart';
import 'package:sport_meet/application/presentation/home/home_page.dart';
import 'package:sport_meet/application/presentation/search/meet_page.dart';
import 'package:sport_meet/application/presentation/widgets/field_card.dart';
import 'package:sport_meet/application/presentation/fields/manage_fields_page.dart';
import 'package:sport_meet/application/presentation/fields/favorite_fields_page.dart';
import 'package:sport_meet/application/presentation/chat_page.dart';
import 'package:sport_meet/profile/profile_screen.dart';
import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';
import 'package:http/http.dart' as http;
import 'package:sport_meet/application/presentation/search/search_widgets/search_bar.dart' as custom;
import 'package:sport_meet/application/presentation/search/search_widgets/sports_chips.dart';
import 'package:sport_meet/application/presentation/search/search_widgets/field_list.dart';
import 'package:sport_meet/application/presentation/search/search_widgets/filter_dialog.dart';
import 'package:sport_meet/application/presentation/search/search_widgets/search_app_bar.dart';
import 'package:sport_meet/application/presentation/search/search_widgets/search_bottom_nav.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
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
  String selectedSortOption = '';
  List<dynamic> fieldData = [];
  List<dynamic> filteredFieldData = [];
  bool? isPublicFilter;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Authentication.getUserSports().then((value) {
      setState(() {
        sportsFilters = value ?? [];
        selectedSports = List.from(sportsFilters); // Initially select all sports
        fetchUserData(); // Fetch user data after setting sports filters
        fetchFieldsData(); // Load the fields data from API
      });
    });
  }

  Future<void> fetchFieldsData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/fields'));
      if (response.statusCode == 200) {
        setState(() {
          fieldData = json.decode(response.body) ?? [];
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
  }

  @override
  void dispose() {
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

  void _resetFilters() {
    setState(() {
      selectedSports = List.from(sportsFilters);
      isPublicFilter = null;
      selectedTime = null;
      filteredFieldData = List.from(fieldData);
    });
  }

  void _applyFilters() {
    setState(() {
      filteredFieldData = fieldData.where((field) {
        return _filterBySports(field) &&
            _filterByPublicStatus(field) &&
            _filterByTime(field);
      }).toList();
    });
  }

  bool _filterBySports(dynamic field) {
    return selectedSports.isEmpty ||
        selectedSports.contains(field['sport']?.toString().toLowerCase() ?? '');
  }

  bool _filterByPublicStatus(dynamic field) {
    return isPublicFilter == null ||
        (field['isPublic'] != null && field['isPublic'] == isPublicFilter);
  }

  bool _filterByTime(dynamic field) {
    if (selectedTime == null) return true;
    final fieldOpenTime = _parseTime(field['schedule']['open'] ?? '00:00');
    final fieldCloseTime = _parseTime(field['schedule']['close'] ?? '23:59');
    return selectedTime!.hour >= fieldOpenTime.hour &&
        selectedTime!.hour < fieldCloseTime.hour;
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        sportsFilters: sportsFilters,
        selectedSports: selectedSports,
        isPublicFilter: isPublicFilter,
        selectedTime: selectedTime,
        onApply: _applyFilters,
        onClear: _resetFilters,
        onPublicFilterChanged: (value) => setState(() => isPublicFilter = value),
        onTimeChanged: (time) => setState(() => selectedTime = time),
      ),
    );
  }

  int countActiveFilters() {
    int count = 0;

    count += sportsFilters.length - selectedSports.length;
    count += 2 - selectedTeamAvailability.length;

    if (selectedStartDate != null || selectedEndDate != null) {
      count += 1;
    }

    if (selectedTime != null) {
      count += 1;
    }

    return count;
  }

  void _onBottomNavTapped(int index) {
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
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFieldData = fieldData.where((field) {
      final sport = field['sport']?.toString().toLowerCase() ?? '';
      final location = field['location']?.toString().toLowerCase() ?? '';
      final isPublic = field['isPublic']?.toString().toLowerCase() ?? '';
      final name = field['name']?.toString().toLowerCase() ?? '';
      final openTime = field['schedule']['open']?.toString().toLowerCase() ?? '';
      final closeTime = field['schedule']['close']?.toString().toLowerCase() ?? '';
      final query = _searchController.text.toLowerCase();

      final matchesSearchQuery = sport.contains(query) ||
          location.contains(query) ||
          isPublic.contains(query) ||
          name.contains(query) ||
          openTime.contains(query) ||
          closeTime.contains(query);

      final matchesSelectedSports = selectedSports.contains(field['sport']);
      final isPublicMatch = isPublicFilter == null ||
          (field['isPublic'] != null && field['isPublic'] == isPublicFilter);

      final fieldOpenTime = _parseTime(field['schedule']['open'] ?? '00:00');
      final fieldCloseTime = _parseTime(field['schedule']['close'] ?? '23:59');

      final timeMatch = selectedTime == null ||
          (selectedTime!.hour >= fieldOpenTime.hour &&
              selectedTime!.hour < fieldCloseTime.hour);

      return matchesSearchQuery &&
          matchesSelectedSports &&
          isPublicMatch &&
          timeMatch;
    }).toList();

    return Scaffold(
      appBar: SearchAppBar(onMeetPageNavigate: _navigateToMeetPage),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: custom.SearchBar(
                    searchController: _searchController,
                    onClear: () => setState(() => _searchController.clear()),
                    onFilter: _showFilterDialog,
                  ),
                ),
                const SizedBox(width: 10),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Ionicons.filter_outline),
                      onPressed: _showFilterDialog,
                    ),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SportsChips(
              sportsFilters: sportsFilters,
              selectedSports: selectedSports,
              onToggleSport: toggleSportFilter,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FieldList(filteredFieldData: filteredFieldData),
          ),
        ],
      ),
      bottomNavigationBar: SearchBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        isHostUser: isHostUser,
      ),
    );
  }
}