import 'package:ecotrecko/login/presentation/common/wrapper.dart';
import 'package:ecotrecko/login/presentation/friends/friends_page.dart';
import 'package:ecotrecko/login/presentation/admin_page.dart';
import 'package:ecotrecko/login/presentation/goal_page.dart';
import 'package:ecotrecko/login/presentation/home/goal_card.dart';
import 'package:ecotrecko/login/presentation/home/home_card.dart';
import 'package:ecotrecko/login/presentation/home/map_card.dart';
import 'package:ecotrecko/login/presentation/notifications/notifications_screen.dart';
import 'package:ecotrecko/login/presentation/ranking_screen.dart';
import 'package:ecotrecko/login/presentation/forms/transportation_page.dart';
import 'package:ecotrecko/login/presentation/welcome/welcome_page.dart';
import 'package:ecotrecko/login/themes/light_theme.dart';
import 'package:ecotrecko/login/themes/theme_manager.dart';
import 'package:ecotrecko/map_template/darkTemplate.dart';
import 'package:ecotrecko/map_template/lightTemplate.dart';
import 'package:ecotrecko/profile/profile_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecotrecko/login/themes/dark_theme.dart';
import 'package:ecotrecko/login/application/auth.dart';
import 'package:ecotrecko/login/application/user.dart';
import 'package:ecotrecko/login/presentation/DailyTracker/daily_tracker.dart';
import 'package:ecotrecko/login/presentation/about_us_page.dart';
import 'package:ecotrecko/login/presentation/coming_soon_page.dart';
import 'package:ecotrecko/login/presentation/forms/household_page.dart';
import 'package:ecotrecko/login/presentation/map_page.dart';
import 'package:ecotrecko/login/presentation/forms/meals_page.dart';
import 'package:ecotrecko/login/presentation/settings_page.dart';
import 'package:ecotrecko/login/presentation/stats/stats_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:provider/provider.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

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
  late Future<Map<String, dynamic>> userInfo;
  double dailyEmission = 1.61;

  final LatLng _origin = const LatLng(37.7749, -122.4194);
  final LatLng _destination = const LatLng(37.7849, -122.4094);

  bool isOpened = false;

  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();

  late Future<Map<String, Map<String, dynamic>>> _goals;

  @override
  void initState() {
    super.initState();
    userInfo = User.getInfo();
    _goals = Authentication.getGoals();
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

  void rankingsButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RankingScreen(),
      ),
    );
  }

  void logoutButtonPressed() {
    Authentication.logout();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
    );
  }

  void goalsButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GoalPage(),
      ),
    );
  }

  void statsButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StatsPage(),
      ),
    );
  }

  void dailyTrackButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailyTracker(),
      ),
    );
  }

  void comingSoonButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ComingSoonPage(),
      ),
    );
  }

  void mealsButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MealsPage(),
      ),
    );
  }

  void transportationButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransportationPage(),
      ),
    );
  }

  void householdButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HouseholdPage(),
      ),
    );
  }

  void mapButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapPage(),
      ),
    );
  }

  void aboutUsButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutUsPage(),
      ),
    );
  }

  void friendsButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FriendsPage(),
      ),
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

  void goalButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GoalPage(),
      ),
    );
  }

  void adminButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminPage(),
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

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Theme.of(context).colorScheme.background,
          Theme.of(context).colorScheme.primary,
        ],
      ),
    );
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
        body: HawkFabMenu(
            icon: AnimatedIcons.add_event,
            fabColor: Theme.of(context).colorScheme.onPrimary,
            iconColor: Theme.of(context).colorScheme.inversePrimary,
            items: [
              HawkFabMenuItem(
                label: 'Meals',
                labelColor: Theme.of(context).colorScheme.onTertiary,
                labelBackgroundColor: Theme.of(context).colorScheme.onPrimary,
                ontap: mealsButtonPressed,
                icon: Icon(
                  Ionicons.restaurant_outline,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              HawkFabMenuItem(
                label: 'Transportation',
                labelColor: Theme.of(context).colorScheme.onTertiary,
                labelBackgroundColor: Theme.of(context).colorScheme.onPrimary,
                ontap: transportationButtonPressed,
                icon: Icon(
                  Ionicons.car_outline,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              HawkFabMenuItem(
                labelColor: Theme.of(context).colorScheme.onTertiary,
                label: 'Household',
                labelBackgroundColor: Theme.of(context).colorScheme.onPrimary,
                ontap: householdButtonPressed,
                icon: Icon(
                  Ionicons.home_outline,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ],
            body: Stack(fit: StackFit.expand, children: [
              Container(decoration: _buildBackgroundDecoration()),
              SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                                Text(
                                  'Hello EcoTrecker,',
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                            const SizedBox(
                              height: 20,
                            ),
                                Text(
                                  'Your Main Goal For Today,',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                            const SizedBox(
                              height: 10,
                            ),
                            _buildGoalWidget(),
                            const SizedBox(height: 30),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                      Text(
                                        'Your Daily Trackers',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      HomeCard(
                                        title: "Daily Tracker",
                                        icon: Ionicons.analytics_outline,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        onPressed: dailyTrackButtonPressed,
                                      ),
                                      const SizedBox(width: 20),
                                      HomeCard(
                                        title: "Emissions",
                                        icon: Ionicons.bar_chart_outline,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        onPressed: statsButtonPressed,
                                      ),
                                    ],
                                  ),
                                ]),
                            const SizedBox(height: 30),
                                Text(
                                  "Your Daily Route",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                            const SizedBox(height: 10),
                            MapCard(
                              title: "Map",
                              icon: Icons.map,
                              color: Theme.of(context).colorScheme.onPrimary,
                              onPressed: mapButtonPressed,
                            ),
                          ]))),
            ])),
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

  Widget _buildGoalWidget() {
    return FutureBuilder<List<dynamic>>(
        future: Future.wait([_goals, _goals]),
        builder: (context, snapshot) {
          Map<String, dynamic>? goal;

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            Map<String, Map<String, dynamic>> goals = snapshot.data![0];
            if (goals.isNotEmpty) {
              goal = goals.values.elementAt(
                  (goals.length * (DateTime.now().day / 30)).toInt());
            }
          }
          return GoalCard(
            goal: goal,
            onPressed: goalButtonPressed,
          );
        });
  }

  Widget _buildSideMenu() {
    return FutureBuilder<Map<String, dynamic>>(
        future: userInfo,
        builder: (context, snapshot) {
          var userInfo = snapshot.data;

          if (snapshot.hasData) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 90.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Ionicons.people_outline,
                        size: 30,
                        color: Theme.of(context).colorScheme.onSecondary),
                    title: Text('Friends',
                        style: Theme.of(context).textTheme.headlineLarge),
                    onTap: friendsButtonPressed,
                  ),
                  ListTile(
                    leading: Icon(Ionicons.trophy_outline,
                        size: 30,
                        color: Theme.of(context).colorScheme.onSecondary),
                    title: Text('Ranking',
                        style: Theme.of(context).textTheme.headlineLarge),
                    onTap: rankingsButtonPressed,
                  ),
                  ListTile(
                    leading: Icon(Ionicons.bar_chart_outline,
                        size: 30,
                        color: Theme.of(context).colorScheme.onSecondary),
                    title: Text('Statistics',
                        style: Theme.of(context).textTheme.headlineLarge),
                    onTap: statsButtonPressed,
                  ),
                  if (kIsWeb &&
                      (userInfo!['roleCode'] != null &&
                          userInfo['roleCode'] > 0))
                    ListTile(
                      leading: Icon(Ionicons.build_outline,
                          size: 30,
                          color: Theme.of(context).colorScheme.onSecondary),
                      title: Text('Admin Panel',
                          style: Theme.of(context).textTheme.headlineLarge),
                      onTap: adminButtonPressed,
                    ),
                  ListTile(
                    leading: Icon(Ionicons.golf_outline,
                        size: 30,
                        color: Theme.of(context).colorScheme.onSecondary),
                    title: Text('Goals',
                        style: Theme.of(context).textTheme.headlineLarge),
                    onTap: goalsButtonPressed,
                  ),
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
                    onTap: aboutUsButtonPressed,
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
