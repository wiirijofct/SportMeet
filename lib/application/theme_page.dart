import 'package:sport_meet/application/themes/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:provider/provider.dart';
import 'package:sport_meet/application/themes/theme_manager.dart';
import 'package:sport_meet/application/presentation/home/home_page.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  void navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var themeManager = Provider.of<ThemeManager>(context);
    bool isDarkTheme = themeManager.themeData == darkTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.background,
                  Theme.of(context).colorScheme.primary,
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Ionicons.color_palette_outline,
                      size: 40,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Theme',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "Dark mode, is a display setting that uses a dark color scheme for the user interface.",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text(
                    " Its benefits includes:",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 35.0),
                  child: Text(
                    "-Battery Efficiency (40%): Extends battery life on OLED/AMOLED screens.",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 35.0),
                  child: Text(
                    "-Lessens eye fatigue in low-light environments.",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: DayNightSwitcher(
                    isDarkModeEnabled: isDarkTheme,
                    onStateChanged: (isDarkModeEnabled) {
                      themeManager.toggleTheme();
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Ionicons.arrow_back_circle_outline,
                            color: Theme.of(context).colorScheme.onTertiary,
                            size: 30,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
