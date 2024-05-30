import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.deepPurple,
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.cyan,
    titleTextStyle: TextStyle(
      color: Colors.black,
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
  ),
  colorScheme: const ColorScheme.light(
    background: Colors.white, // for scaffoldBackgroundColor
    onBackground: Colors.black, // for text color
    primary: Colors.deepPurple, // for appbar background color
    onPrimary: Colors.black, // for appbar text color
    surface: Color.fromARGB(255, 215, 215, 215), // for card background color
    onSurface: Colors.black, // for card text color
    secondary: Colors.blue, // for button background color
    onSecondary: Colors.black, // for button text color
    onError: Colors.red, // for error text color
    error: Colors.red, // for error background color
    primaryContainer: Colors.white, // for container background color
    secondaryContainer: Colors.cyan, // for container background color
    onPrimaryContainer: Colors.black, // for container text color
    onSecondaryContainer: Colors.black, // for container text color
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.deepOrange,
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xff242424),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[800],
    titleTextStyle: const TextStyle(
      color: Colors.white,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
  ),
  colorScheme: const ColorScheme.dark(
    background: Color(0xff242424), // for scaffoldBackgroundColor
    onBackground: Colors.white, // for text color
    primary: Colors.white, // for appbar background color
    onPrimary: Colors.white, // for appbar text color
    surface: Color(0xff242424), // for card background color
    onSurface: Colors.white, // for card text color
    secondary: Color(0xff246AFE), // for button background color
    onSecondary: Color(0xff000000), // for button text color
    onError: Colors.red, // for error text color
    error: Colors.red, // for error background color
    primaryContainer: Color(0xff373737), // for container background color
    secondaryContainer: Color(0xff373737), // for container background color
    onPrimaryContainer: Colors.white, // for container text color
    onSecondaryContainer: Colors.white, // for container text color
  ),
);
