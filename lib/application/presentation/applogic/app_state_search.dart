import 'package:flutter/material.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';
import 'package:sport_meet/application/presentation/applogic/fields_service.dart';

class SearchPageState extends ChangeNotifier {
  List<String> sportsFilters = [];
  List<String> selectedSports = [];
  bool isFree = false;
  bool isHostUser = false;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  TimeOfDay? selectedTime;
  String selectedSortOption = '';
  List<dynamic> fieldData = [];
  List<dynamic> filteredFieldData = [];
  bool? isPublicFilter;
  String searchText = '';
  final FieldsService _fieldsService = FieldsService();
  int _currentIndex = 0;

  SearchPageState() {
    _initializeState();
  }

  Future<void> _initializeState() async {
    await fetchFieldsData();
    fetchUserData();
  }

  Future<void> fetchFieldsData() async {
    try {
      final fields = await _fieldsService.fetchFields();
      fieldData = fields;
      filteredFieldData = fieldData;
      sportsFilters = _fieldsService.getUniqueSports(fields);
      notifyListeners();
    } catch (e) {
      print('Error fetching fields data: $e');
    }
  }

  void fetchUserData() {
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
    applyFilters();
    notifyListeners();
  }

  void resetFilters() {
    selectedSports = [];
    isFree = false;
    selectedStartDate = null;
    selectedEndDate = null;
    selectedTime = null;
    selectedSortOption = '';
    isPublicFilter = null;
    searchText = '';
    filteredFieldData = fieldData;
    notifyListeners();
  }

  Future<void> applyFilters() async {
  List<dynamic> reservations = [];
  if (selectedTime != null) {
    reservations = await _fieldsService.fetchReservations();
  }

  filteredFieldData = fieldData.where((field) {
    final sportsMatch = selectedSports.isEmpty ||
        selectedSports.any((sport) =>
            field['sport'].toString().toLowerCase() == sport.toLowerCase());

    final isPublicMatch = isPublicFilter == null ||
        (field['isPublic'] != null && field['isPublic'] == isPublicFilter);


    final timeMatch = selectedTime == null ||
        _fieldsService.getFieldsByReservations([field], reservations, selectedTime!).isNotEmpty;

    final searchTextMatch = searchText.isEmpty ||
        field['sport'].toString().toLowerCase().contains(searchText.toLowerCase()) ||
        field['name'].toString().toLowerCase().contains(searchText.toLowerCase()) ||
        field['location'].toString().toLowerCase().contains(searchText.toLowerCase());

    return sportsMatch && isPublicMatch && timeMatch && searchTextMatch;
  }).toList();
  notifyListeners();
}

  void updateSearchText(String text) {
    searchText = text;
    applyFilters();
  }


  int countActiveFilters() {
    int count = 0;

    count += selectedSports.length;

    if (selectedStartDate != null || selectedEndDate != null) {
      count += 1;
    }

    if (selectedTime != null) {
      count += 1;
    }

    if (isPublicFilter != null) {
      count += 1;
    }

    return count;
  }

  int get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
