import 'package:sport_meet/profile/profile_screen.dart';
import 'package:sport_meet/application/presentation/notifications/notifications_screen.dart';
import 'package:sport_meet/application/presentation/settings_page.dart';
import 'package:sport_meet/application/presentation/welcome/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:sport_meet/application/themes/theme_manager.dart';
import 'package:sport_meet/application/themes/dark_theme.dart';
import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';
import 'package:sport_meet/application/presentation/widgets/event_card.dart';
import 'package:sport_meet/application/presentation/search/search_page.dart';
import 'package:sport_meet/profile/profileSportMeet.dart';
import 'package:sport_meet/application/presentation/manage_fields_page.dart';
import 'package:sport_meet/application/presentation/favorite_fields_page.dart';
import 'package:sport_meet/application/presentation/chat_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    Authentication.getUserSports().then((value) {
      setState(() {
        sportsFilters = value;
        selectedSports =
            List.from(sportsFilters); // Initially select all sports
        fetchUserData(); // Fetch user data after setting sports filters
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchUserData();
  }

  void fetchUserData() {
    userInfo = User.getInfo();
    userInfo.then((value) {
      setState(() {
        isHostUser = value['hostUser'] ?? false;
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
                  print('Loaded events: $events');

                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventCard(
                        reservationId: int.parse(event['reservationId']),
                        fieldId: int.parse(event['fieldId']),
                        sport: event['sport'],
                        date: event['date'],
                        address: event['location'],
                        field: event['name'],
                        availability: event['teamAvailability'],
                        imagePath: event['images'][0],
                        time: event['time'],
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
                  builder: (context) => const SearchPage(),
                ),
              );
            }
              else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatPage(),
                ),
              );
            }
             else if (index == 3) {
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
    var themeManager = Provider.of<ThemeManager>(context);
    bool isDarkTheme = themeManager.themeData == darkTheme;

    return AppBar(
      toolbarHeight: 70,
      centerTitle: true,
      backgroundColor: isDarkTheme
          ? Colors.black.withOpacity(0.1)
          : Colors.white.withOpacity(0.15),
      leading: IconButton(
        icon: Icon(Ionicons.menu_outline,
            color: Theme.of(context).colorScheme.onTertiary, size: 40),
        onPressed: toggleMenu,
      ),
      title: Image.asset(
        isDarkTheme ? 'lib/images/Logo2.png' : 'lib/images/Logo.png',
        fit: BoxFit.contain,
        height: 60,
      ),
      actions: [
        IconButton(
          icon: Icon(Ionicons.notifications_circle_outline,
              color: Theme.of(context).colorScheme.onTertiary, size: 40),
          onPressed: notificationsButtonPressed,
        ),
        IconButton(
          icon: Icon(Ionicons.person_circle_outline,
              color: Theme.of(context).colorScheme.onTertiary, size: 40),
          onPressed: profileButtonPressed,
        ),
      ],
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
                    leading: Icon(Ionicons.information_circle_outline,
                        size: 30,
                        color: Theme.of(context).colorScheme.onSecondary),
                    title: Text('About Us',
                        style: Theme.of(context).textTheme.headlineLarge),
                    onTap: () {},
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
