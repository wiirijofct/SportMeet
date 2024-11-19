import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool isFree = false;
  bool showOpenTeam = false;
  List<String> sportsFilters = ['Basketball', 'Tennis', 'Swimming', 'Football'];
  List<String> selectedSports = [];
  List<String> selectedAvailability = [];
  List<String> selectedMunicipality = [];
  String selectedGender = '';
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String selectedSortOption = '';
  List<Map<String, dynamic>> filteredEvent = [];
  List<Map<String, dynamic>> meetPeople = [];

  void setMeetPeople(List<Map<String, dynamic>> users) {
    meetPeople = users;
    filteredEvent = List.from(meetPeople);
    notifyListeners();
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
    selectedSports = [];
    selectedAvailability = [];
    selectedMunicipality = [];
    selectedGender = '';
    isFree = false;
    showOpenTeam = false;
    selectedStartDate = null;
    selectedEndDate = null;
    selectedSortOption = '';
    filteredEvent = List.from(meetPeople);
    notifyListeners();
  }

  void applyFilters() {
    Set<String> expandedAvailability = selectedAvailability.toSet();
    if (selectedAvailability.contains('Weekends')) {
      expandedAvailability.add('All days');
    }
    if (selectedAvailability.any((day) => ['Saturdays', 'Sundays'].contains(day))) {
      expandedAvailability.add('Weekends');
    }
    if (selectedAvailability.any((day) => 
        ['Mondays', 'Tuesdays', 'Wednesdays', 'Thursdays', 'Fridays'].contains(day))) {
      expandedAvailability.add('All days');
    }

    filteredEvent = meetPeople.where((person) {
      final sportsMatch = selectedSports.isEmpty || selectedSports.any((sport) => person['sports']!.contains(sport));
      final availabilityMatch = expandedAvailability.isEmpty || 
          expandedAvailability.any((day) => person['availability']!.contains(day));
      final municipalityMatch = selectedMunicipality.isEmpty || 
          selectedMunicipality.contains(person['address']!.split(': ')[1]);
      final genderMatch = selectedGender.isEmpty || 
          person['gender']!.contains(selectedGender);

      return sportsMatch && availabilityMatch && municipalityMatch && genderMatch;
    }).toList();
    notifyListeners();
  }
}