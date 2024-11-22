import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    brightness: Brightness.light,
    primary: Color.fromARGB(255, 181, 2, 2),
    surface: Color.fromARGB(255, 226, 224, 224),
    tertiary: Color.fromARGB(235, 195, 49, 49),
    onPrimary: Color.fromARGB(162, 255, 255, 255),
    onSecondary: Color.fromARGB(255, 31, 31, 31),
    onTertiary: Colors.black,
    inversePrimary: Colors.black,
    primaryContainer: Color.fromARGB(239, 156, 170, 167),
    onSecondaryContainer: Colors.white,
    onTertiaryContainer: Color.fromARGB(255, 68, 2, 2),
    onSurfaceVariant: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 181, 2, 2),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
        fontSize: 35,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: "FredokaRegular"),
    titleMedium: TextStyle(
      fontFamily: "FredokaRegular",
      fontSize: 23,
      color: Colors.black,
    ),
    titleSmall: TextStyle(
      fontFamily: "FredokaRegular",
      fontSize: 20,
      color: Colors.black,
    ),
    headlineLarge: TextStyle(
        fontFamily: 'FredokaRegular', 
        fontSize: 25, 
        color: Colors.black),
    headlineMedium: TextStyle(
      fontFamily: "FredokaRegular",
      fontSize: 23,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(
      fontSize: 24,
      color: Colors.black,
      fontFamily: "FredokaRegular",
    ),
    bodyMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      fontFamily: 'FredokaRegular',
      color: Colors.black,
    ),
    bodySmall: TextStyle(
      fontFamily: "FredokaRegular",
      fontSize: 16,
      color: Colors.black,
    ),
    labelMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontFamily: "FredokaRegular",
    ),
    labelSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontFamily: "FredokaRegular",
    ),
    headlineSmall: TextStyle(
      fontSize: 15,
      color: Colors.black,
      fontFamily: "FredokaRegular",
    ),
    displaySmall: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontFamily: "FredokaRegular",
    ),
    displayMedium: TextStyle(
      fontSize: 17,
      color: Colors.black,
      fontFamily: "FredokaRegular",
    ),
    displayLarge: TextStyle(
      color: Color.fromARGB(255, 255, 0, 17),
      fontSize: 12,
      fontFamily: "FredokaRegular",
    ),
  ),
);