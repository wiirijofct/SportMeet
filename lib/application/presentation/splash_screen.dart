import 'package:sport_meet/application/presentation/welcome/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:sport_meet/application/presentation/home/home_page.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLogged = false;

  @override
  void initState() {
    super.initState();
    // Set a default value for isLogged (you can adjust based on your needs)
    isLogged = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(50),
            child: FlutterSplashScreen.gif(
              backgroundColor: Colors.white,
              gifPath: 'lib/images/animated_logo.gif',
              gifWidth: 592,
              gifHeight: 948,
              nextScreen: isLogged ? const HomePage() : const WelcomePage(),
              duration: const Duration(milliseconds: 4000),
            ),
          ),
        ],
      ),
    );
  }
}