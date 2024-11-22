import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';

class SearchPageState extends ChangeNotifier {
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

  SearchPageState() {
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _fetchUserSports();
    await fetchFieldsData();
    fetchUserData();
  }

  Future<void> _fetchUserSports() async {
    // Replace with actual method to fetch user sports
    sportsFilters = await Authentication.getUserSports();
    selectedSports = List.from(sportsFilters);
    notifyListeners();
  }

  Future<void> fetchFieldsData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/fields'));
      if (response.statusCode == 200) {
        fieldData = json.decode(utf8.decode(response.bodyBytes));
        filteredFieldData = fieldData;
        notifyListeners();
      } else {
        throw Exception('Failed to load fields');
      }
    } catch (e) {
      print('Error fetching fields data: $e');
    }
  }

  void fetchUserData() {
    // Replace with actual method to fetch user data
    User.getInfo().then((value) {
      isHostUser = value['hostUser'] ?? false;
      notifyListeners();
    });
  }

  void toggleSportFilter(String sport) {
    if (selectedSports.contains(sport)) {
      selectedSports.remove(sport);
    } else {
      selectedSports.add(sport);
    }
    notifyListeners();
  }

  void resetFilters() {
    selectedSports = List.from(sportsFilters);
    isFree = false;
    showOpenTeam = false;
    selectedStartDate = null;
    selectedEndDate = null;
    selectedTime = null;
    selectedSortOption = '';
    isPublicFilter = null;
    filteredFieldData = fieldData;
    notifyListeners();
  }

  void applyFilters() {
    filteredFieldData = fieldData.where((field) {
      final sportsMatch = selectedSports.isEmpty ||
          selectedSports.any((sport) =>
              field['sport'].toString().toLowerCase().contains(sport));

      final isPublicMatch = isPublicFilter == null ||
          (field['isPublic'] != null && field['isPublic'] == isPublicFilter);

      final fieldOpenTime = _parseTime(field['schedule']['open']);
      final fieldCloseTime = _parseTime(field['schedule']['close']);

      final timeMatch = selectedTime == null ||
          (selectedTime!.hour >= fieldOpenTime.hour &&
              selectedTime!.hour < fieldCloseTime.hour);

      return sportsMatch && isPublicMatch && timeMatch;
    }).toList();
    notifyListeners();
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}