import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_meet/application/presentation/splash_screen.dart';
import 'package:sport_meet/application/themes/theme_manager.dart';
import 'package:sport_meet/application/presentation/applogic/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Authentication.initializeUsers();
  await Authentication.initializeFields();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return MaterialApp(
          title: 'SportMeet',
          debugShowCheckedModeBanner: true,
          navigatorKey: navigatorKey,
          theme: themeManager.themeData,
          home: const SplashScreen(),
        );
      },
    );
  }
}