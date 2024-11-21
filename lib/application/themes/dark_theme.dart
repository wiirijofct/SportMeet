import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
    brightness: Brightness.dark,
    primary: Color.fromARGB(255, 180, 50, 50),
    surface: Color.fromARGB(255, 221, 221, 221),
    tertiary: Color.fromARGB(255, 180, 50, 50),
    onPrimary: Color.fromARGB(255, 180, 50, 50),
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    inversePrimary: Color.fromARGB(255, 206, 206, 206),
    primaryContainer: Color.fromARGB(238, 170, 156, 156),
    onSecondaryContainer: Color.fromARGB(255, 219, 219, 219),
    onTertiaryContainer: Color.fromARGB(239, 206, 0, 0),
    onSurfaceVariant: Color.fromARGB(255, 55, 3, 3),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 180, 50, 50),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
        fontSize: 35,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: "FredokaRegular"),
    titleMedium: TextStyle(
      fontFamily: "FredokaRegular",
      fontSize: 23,
      color: Color.fromARGB(255, 226, 226, 226),
    ),
    titleSmall: TextStyle(
      fontFamily: "FredokaRegular",
      fontSize: 20,
      color: Colors.white,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'FredokaRegular',
      fontSize: 25,
      color: Color.fromARGB(255, 224, 224, 224),
    ),
    headlineMedium: TextStyle(
      fontFamily: "FredokaRegular",
      fontSize: 23,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 194, 194, 194),
    ),
    bodyMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      fontFamily: 'FredokaRegular',
      color: Color.fromARGB(255, 189, 189, 189),
    ),
    bodySmall: TextStyle(
      fontFamily: "FredokaRegular",
      fontSize: 16,
      color: Color.fromARGB(255, 197, 197, 197),
    ),
    labelMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: "FredokaRegular",
    ),
    bodyLarge: TextStyle(
      fontSize: 24,
      color: Colors.white,
      fontFamily: "FredokaRegular",
    ),
    labelSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 153, 153, 153),
      fontFamily: "FredokaRegular",
    ),
    headlineSmall: TextStyle(
      fontSize: 15,
      color: Colors.white,
      fontFamily: "FredokaRegular",
    ),
    displaySmall: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: "FredokaRegular",
    ),
    displayMedium: TextStyle(
      fontSize: 17,
      color: Colors.white,
      fontFamily: "FredokaRegular",
    ),
    displayLarge: TextStyle(
      color: Color(0xff690005),
      fontSize: 11,
      fontFamily: "FredokaRegular",
    ),
  ),
);