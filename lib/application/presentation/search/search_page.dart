import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:sport_meet/application/presentation/home/home_page.dart';
import 'package:sport_meet/application/presentation/search/meet_page.dart';
import 'package:sport_meet/application/presentation/fields/manage_fields_page.dart';
import 'package:sport_meet/application/presentation/fields/favorite_fields_page.dart';
import 'package:sport_meet/application/presentation/chat_page.dart';
import 'package:sport_meet/profile/profile_screen.dart';
import 'package:sport_meet/application/presentation/search/search_widgets/search_bar.dart' as custom;
import 'package:sport_meet/application/presentation/search/search_widgets/sports_chips.dart';
import 'package:sport_meet/application/presentation/search/search_widgets/field_list.dart';
import 'package:sport_meet/application/presentation/search/search_widgets/filter_dialog.dart';
import 'package:sport_meet/application/presentation/search/search_widgets/search_app_bar.dart';
import 'package:sport_meet/application/presentation/search/search_widgets/search_bottom_nav.dart';
import 'package:sport_meet/application/presentation/applogic/app_state_search.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToMeetPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const MeetPage(),
    ));
  }

  void _showFilterDialog(BuildContext context) {
    final searchPageState = Provider.of<SearchPageState>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        sportsFilters: searchPageState.sportsFilters,
        selectedSports: searchPageState.selectedSports,
        isPublicFilter: searchPageState.isPublicFilter,
        selectedTime: searchPageState.selectedTime,
        onApply: searchPageState.applyFilters,
        onClear: searchPageState.resetFilters,
        onPublicFilterChanged: (value) => searchPageState.isPublicFilter = value,
        onTimeChanged: (time) => searchPageState.selectedTime = time,
      ),
    );
  }

  void _onBottomNavTapped(BuildContext context, int index) {
    final searchPageState = Provider.of<SearchPageState>(context, listen: false);
    searchPageState.currentIndex = index;
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
      if (searchPageState.isHostUser) {
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
    return ChangeNotifierProvider(
      create: (_) => SearchPageState(),
      child: Consumer<SearchPageState>(
        builder: (context, searchPageState, child) {
          return Scaffold(
            appBar: SearchAppBar(onMeetPageNavigate: () => _navigateToMeetPage(context)),
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
                          onSearchChanged: searchPageState.updateSearchText,
                          onClear: () {
                            _searchController.clear();
                            searchPageState.resetFilters();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Ionicons.filter_outline,
          color: Colors.black, ),
                            onPressed: () => _showFilterDialog(context),
                          ),
                          if (searchPageState.countActiveFilters() > 0)
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: Colors.brown,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: Center(
                                  child: Text(
                                    '${searchPageState.countActiveFilters()}',
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
                    sportsFilters: searchPageState.sportsFilters,
                    selectedSports: searchPageState.selectedSports,
                    onToggleSport: searchPageState.toggleSportFilter,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: FieldList(filteredFieldData: searchPageState.filteredFieldData),
                ),
              ],
            ),
            bottomNavigationBar: SearchBottomNavigationBar(
              currentIndex: searchPageState.currentIndex,
              onTap: (index) => _onBottomNavTapped(context, index),
              isHostUser: searchPageState.isHostUser,
            ),
          );
        },
      ),
    );
  }
}