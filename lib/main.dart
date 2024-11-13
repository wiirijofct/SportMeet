import 'package:sport_meet/application/presentation/splash_screen.dart';
import 'package:sport_meet/application/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  // DailyTrackerConfig.start();

  runApp(
    ChangeNotifierProvider(
      create : (context) => ThemeManager(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportMeet',
      debugShowCheckedModeBanner: true,
      navigatorKey: navigatorKey,
      theme: Provider.of<ThemeManager>(context).themeData,

      home: const SplashScreen()
    );
  }
}
