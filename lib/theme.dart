import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins', // ✅ Moved here, accepted
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF004AAD),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF1F3F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF004AAD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF004AAD)),
      titleTextStyle: TextStyle(
        color: Color(0xFF004AAD),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF004AAD),
      secondary: Colors.blueGrey,
    ),
    scaffoldBackgroundColor: Colors.black,
  );
}
