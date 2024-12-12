import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:sport_meet/application/themes/light_theme.dart';
import 'package:sport_meet/application/themes/theme_manager.dart';
import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';
import 'package:sport_meet/application/presentation/widgets/event_card.dart';
import 'package:sport_meet/application/presentation/search/search_page.dart';
import 'package:sport_meet/application/presentation/fields/manage_fields_page.dart';
import 'package:sport_meet/application/presentation/fields/favorite_fields_page.dart';
import 'package:sport_meet/application/presentation/chat_page.dart';
import 'package:sport_meet/profile/profile_screen.dart';
import 'package:sport_meet/application/presentation/notifications/notifications_screen.dart';
import 'package:sport_meet/application/presentation/settings_page.dart';
import 'package:sport_meet/application/presentation/welcome/welcome_page.dart';
import 'package:sport_meet/application/presentation/reservation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  late Future<Map<String, dynamic>> userInfo;
  late Future<List<Map<String, dynamic>>> userEvents;
  List<String> sportsFilters = [];
  List<String> selectedSports = [];
  bool isHostUser = false;
  bool themeUpdated = false;

  @override
  void initState() {
    super.initState();
    Authentication.getUserSports().then((value) {
      setState(() {
        sportsFilters = value;
        selectedSports = List.from(sportsFilters);
        fetchUserData();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!themeUpdated) {
      fetchUserData();
    }
  }

  void fetchUserData() {
    userInfo = User.getInfo();
    userInfo.then((value) {
      setState(() {
        isHostUser = value['hostUser'] ?? false;
        // Update the theme based on the user's role
        if (!themeUpdated) {
          if (isHostUser) {
            Provider.of<ThemeManager>(context, listen: false).themeData = lightTheme.copyWith(
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
              ),
              colorScheme: lightTheme.colorScheme.copyWith(
                secondary: Colors.blue,
                tertiary: Colors.blue.shade100,
              ),
            );
          } else {
            Provider.of<ThemeManager>(context, listen: false).themeData = lightTheme.copyWith(
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.red,
              ),
            );
          }
          themeUpdated = true; // Set the flag to true after updating the theme
        }
      });
    });
    userEvents = Authentication.getUserFilteredCompleteEvents(selectedSports);
  }
  
  void profileButtonPressed() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void notificationsButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsPage(),
      ),
    );
  }

  void logoutButtonPressed() {
    Authentication.logoutUser();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
    );
  }

  void settingButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  void toggleMenu() {
    final state = _sideMenuKey.currentState!;
    if (state.isOpened) {
      state.closeSideMenu();
    } else {
      state.openSideMenu();
    }
  }

  void toggleSportFilter(String sport) {
    setState(() {
      if (selectedSports.contains(sport)) {
        selectedSports.remove(sport);
      } else {
        selectedSports.add(sport);
      }
      userEvents = Authentication.getUserFilteredCompleteEvents(selectedSports);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SideMenu(
      key: _sideMenuKey,
      menu: _buildSideMenu(),
      background: Theme.of(context).colorScheme.tertiary,
      type: SideMenuType.slideNRotate,
      onChange: (isOpened) {
        setState(() => isOpened = isOpened);
      },
      closeIcon: Icon(Ionicons.close_outline,
          color: Theme.of(context).colorScheme.onSecondary),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Upcoming Events',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: userEvents,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print('Error loading events: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    print('No upcoming events found.');
                    return const Center(child: Text('No upcoming events'));
                  }

                  final events = snapshot.data!;

                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReservationPage(
                                reservationId: event['reservationId'],
                                fieldId: event['fieldId'],
                              ),
                            ),
                          );
                          if (result == true) {
                            // Reload the user events
                            setState(() {
                              userEvents = Authentication.getUserFilteredCompleteEvents(selectedSports);
                            });
                          }
                        },
                        child: EventCard(
                          reservationId: int.parse(event['reservationId']),
                          fieldId: int.parse(event['fieldId']),
                          sport: event['sport'],
                          date: event['date'],
                          address: event['location'],
                          field: event['name'],
                          imagePath: event['images'][0],
                          time: event['time'],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Ionicons.search),
              label: 'Search',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Ionicons.chatbubble_ellipses_outline),
              label: 'Chat',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Ionicons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(isHostUser ? Ionicons.add : Ionicons.heart_outline),
              label: isHostUser ? 'Field' : 'Favorites',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Ionicons.person_outline),
              label: 'Profile',
            ),
          ],
          currentIndex: 2,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(),
                ),
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
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 70,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Ionicons.menu_outline,
            color: Theme.of(context).colorScheme.onTertiary, size: 40),
        onPressed: toggleMenu,
      ),
      title: Image.asset(
        'lib/images/Logo.png',
        fit: BoxFit.contain,
        height: 60,
      ),
    );
  }

  Widget _buildSideMenu() {
    return FutureBuilder<Map<String, dynamic>>(
        future: userInfo,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 90.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Ionicons.settings_outline,
                        size: 30,
                        color: Theme.of(context).colorScheme.onSecondary),
                    title: Text('Settings',
                        style: Theme.of(context).textTheme.headlineLarge),
                    onTap: settingButtonPressed,
                  ),
                  ListTile(
                    leading: Icon(Icons.exit_to_app,
                        size: 30,
                        color: Theme.of(context).colorScheme.onSecondary),
                    title: Text('Logout',
                        style: Theme.of(context).textTheme.headlineLarge),
                    onTap: logoutButtonPressed,
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const CircularProgressIndicator();
        });
  }
}