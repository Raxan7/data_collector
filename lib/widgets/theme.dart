import 'package:flutter/material.dart';

final darkTheme = ThemeData.dark().copyWith(
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF00695C), // Dark green
    secondary: Color(0xFF01579B), // Dark blue
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF1E1E1E),
    border: OutlineInputBorder(),
  ),
);
