import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.black,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        brightness: Brightness.dark,
        surface: AppColors.black,
        background: AppColors.black,
        onBackground: AppColors.beige,
        onSurface: AppColors.beige,
      ),
      fontFamily: 'ReginaBlack',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.beige, fontSize: 18),
        bodyMedium: TextStyle(color: AppColors.beige, fontSize: 16),
        headlineMedium: TextStyle(
          color: AppColors.beige,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.beige,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.black,
        selectedItemColor: AppColors.beige,
        unselectedItemColor: AppColors.beige,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'ReginaBlack',
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'ReginaBlack',
        ),
      ),
    );
  }
}
