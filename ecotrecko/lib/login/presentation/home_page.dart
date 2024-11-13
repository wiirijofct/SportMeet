import 'package:ecotrecko/login/presentation/friends/friends_page.dart';
import 'package:ecotrecko/login/presentation/admin_page.dart';
import 'package:ecotrecko/login/presentation/goal_page.dart';
import 'package:ecotrecko/login/presentation/notifications/notifications_screen.dart';
import 'package:ecotrecko/login/presentation/ranking_screen.dart';
import 'package:ecotrecko/login/presentation/forms/transportation_page.dart';
import 'package:ecotrecko/login/presentation/welcome/welcome_page.dart';
import 'package:ecotrecko/login/themes/theme_manager.dart';
import 'package:ecotrecko/map_template/darkTemplate.dart';
import 'package:ecotrecko/map_template/lightTemplate.dart';
import 'package:ecotrecko/profile/profile_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecotrecko/login/themes/dark_theme.dart';
import 'package:ecotrecko/login/themes/light_theme.dart';
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
  double dailyEmission = 1.61; // Example value

  final LatLng _origin =
      const LatLng(37.7749, -122.4194); // Example coordinates
  final LatLng _destination =
      const LatLng(37.7849, -122.4094); // Example coordinates
  bool isOpened = false;

  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();

  late Future<Map<String, Map<String, dynamic>>> _goals;
  late Future<Map<String, Map<String, dynamic>>> _progress;

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
        builder: (context) => MapPage(),
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
        extendBodyBehindAppBar: true,
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
            //const Color.fromARGB(120, 148, 221, 165),
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
          body: Container(
            decoration: _buildBackgroundDecoration(),
            child: Stack(
              children: [
                
                _buildGreetingText(),
                _buildGoalLabel(),
                _buildGoalWidget(),
                _buildTrackerStatsLabel(),
                _buildGPSAndCarbonButtonRow(),
                _buildMapLabel(),
                _buildMapButton(),
                _buildHabitTextLabel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Ionicons.menu_outline,
            color: Theme.of(context).colorScheme.onTertiary, size: 45),
        padding: const EdgeInsets.only(left: 20, top: 15),
        onPressed: toggleMenu,
      ),
      title: Center(
        child: GestureDetector(
          onTap: aboutUsButtonPressed,
          child: Container(
            width: 150,
            height: 200,
            padding: const EdgeInsets.only(top: 15),
            child: const AspectRatio(
              aspectRatio: 1.2,
              child: Image(
                image: AssetImage('lib/images/Logo.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Ionicons.notifications_circle_outline,
              color: Theme.of(context).colorScheme.onTertiary, size: 45),
          padding: const EdgeInsets.only(right: 5, top: 15),
          onPressed: notificationsButtonPressed,
        ),
        IconButton(
          icon: Icon(Ionicons.person_circle_outline,
              color: Theme.of(context).colorScheme.onTertiary, size: 45),
          padding: const EdgeInsets.only(right: 20, top: 15),
          onPressed: profileButtonPressed,
        ),
      ],
    );
  }

  Widget _buildGreetingText() {
    return Positioned(
      top: 70,
      left: 20,
      child: Text(
        'Hello EcoTrecker,',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildGoalLabel() {
    return Positioned(
      top: 120,
      left: 20,
      child: Text(
        'Your Main Goal For Today',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }

  Widget _buildTrackerStatsLabel() {
    return Positioned(
      top: 320,
      left: 20,
      child: Text(
        'Your Daily Trackers',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }

  Widget _buildGoalWidget() {
    return FutureBuilder<List<dynamic>>(
        future: Future.wait([_goals, _goals]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, Map<String, dynamic>> goals = snapshot.data![0];
            var goal = goals.values
                .toList()[(goals.length * (DateTime.now().day / 30)).toInt()];

            return Positioned(
              top: 155,
              left: 20,
              right: 20,
              child: SizedBox(
                height: 160,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: goalButtonPressed,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal['title'],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          goal['subtitle'],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          goal['why'],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _buildGPSAndCarbonButtonRow() {
    return Positioned(
      top: 350,
      left: 1,
      right: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(
                width: 190,
                // child: Text(
                //   'Your Daily       Tracker',
                //   textAlign: TextAlign.center,
                //   style: Theme.of(context).textTheme.titleSmall,
                // ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 180,
                height: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    padding:
                        const EdgeInsets.only(top: 22, left: 20, right: 20),
                  ),
                  onPressed: dailyTrackButtonPressed,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 19),
                      Icon(
                        Ionicons.analytics_outline,
                        color: Theme.of(context).colorScheme.onTertiary,
                        size: 60,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tracker',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              const SizedBox(
                width: 190,
                // child: Text(
                //   'Your Carbon Footprint',
                //   textAlign: TextAlign.center,
                //   style: Theme.of(context).textTheme.titleSmall,
                // ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 180,
                height: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    padding:
                        const EdgeInsets.only(top: 40, left: 20, right: 20),
                  ),
                  onPressed: statsButtonPressed,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Ionicons.bar_chart_outline,
                        color: Theme.of(context).colorScheme.onTertiary,
                        size: 60,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Emissions',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapLabel() {
    return Positioned(
      top: 520,
      left: 20,
      child: Text(
        'Your Daily Route',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }

  Widget _buildMapButton() {
    return Positioned(
      top: 560,
      left: 16,
      right: 16,
      child: SizedBox(
        width: 170,
        height: 180,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            children: [
              const SizedBox(height: 6),
              GoogleMap(
                style: Provider.of<ThemeManager>(context).themeData == darkTheme
                    ? darkMapStyle
                    : lightMapStyle,
                initialCameraPosition: CameraPosition(
                  target: _origin,
                  zoom: 12.0,
                ),
                markers: {
                  Marker(markerId: const MarkerId('origin'), position: _origin),
                  Marker(
                      markerId: const MarkerId('destination'),
                      position: _destination),
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: [_origin, _destination],
                    color: Colors.teal,
                    width: 5,
                  ),
                },
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: mapButtonPressed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitTextLabel() {
    return Positioned(
      bottom: 12,
      right: 75,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Track Your Habits',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
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
