import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  List<String> sportsFilters = [];
  List<String> selectedSports = [];
  List<String> availabilityFilters = [];
  List<String> selectedAvailability = [];
  List<String> municipalityFilters = [];
  List<String> selectedMunicipality = [];
  String selectedGender = '';
  List<Map<String, dynamic>> filteredEvent = [];
  List<Map<String, dynamic>> meetPeople = [];

  void setMeetPeople(List<Map<String, dynamic>> users) {
    meetPeople = users;
    filteredEvent = List.from(meetPeople);

    // Extract unique sports, availability, and municipality options
    Set<String> sportsSet = {};
    Set<String> availabilitySet = {};
    Set<String> municipalitySet = {};

    for (var user in users) {
      sportsSet.addAll(List<String>.from(user['sports'] ?? []));
      availabilitySet.addAll(List<String>.from(user['availability'] ?? []));
      if (user['municipality'] != null) {
        municipalitySet.add(user['municipality']);
      }
    }

    sportsFilters = sportsSet.toList();
    availabilityFilters = availabilitySet.toList();
    municipalityFilters = municipalitySet.toList();

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
          selectedMunicipality.contains(person['municipality']);
      final genderMatch = selectedGender.isEmpty || 
          person['gender']!.contains(selectedGender);

      return sportsMatch && availabilityMatch && municipalityMatch && genderMatch;
    }).toList();
    notifyListeners();
  }
}