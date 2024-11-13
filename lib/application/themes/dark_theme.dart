import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  
  colorScheme: const ColorScheme.dark(
    brightness: Brightness.dark,
    primary: Color.fromARGB(255, 0, 63, 56),
    surface: Color.fromARGB(239, 0, 93, 65),
    tertiary: Color.fromARGB(255, 2, 68, 54),
    onPrimary: Color.fromARGB(255, 3, 55, 44),
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    inversePrimary: Color.fromARGB(255, 206, 206, 206),
    primaryContainer: Color.fromARGB(239, 156, 170, 167),
    onSecondaryContainer: Color.fromARGB(255, 219, 219, 219),
     onTertiaryContainer:Color(0xF000CE90),
      onSurfaceVariant: Color.fromARGB(255, 3, 55, 44),
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
//Color.fromARGB(255, 85, 85, 85)
