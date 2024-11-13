import 'package:ecotrecko/login/application/daily_tracker.dart';
import 'package:ecotrecko/login/presentation/splash_screen.dart';
import 'package:ecotrecko/login/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  DailyTrackerConfig.start();

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
      title: 'EcoTrecko',
      debugShowCheckedModeBanner: true,
      navigatorKey: navigatorKey,
      theme: Provider.of<ThemeManager>(context).themeData,

      home: const SplashScreen()
    );
  }
}
