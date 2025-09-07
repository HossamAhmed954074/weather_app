import 'package:flutter/material.dart';

/// Core constants used throughout the application
class AppConstants {
  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 300);
  static const Duration normalAnimation = Duration(milliseconds: 500);
  static const Duration slowAnimation = Duration(milliseconds: 800);

  // UI constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 16.0;
  static const double cardElevation = 8.0;

  // Cache constants
  static const String weatherCacheKey = 'cached_weather';
  static const String lastLocationCacheKey = 'last_location';
  static const String settingsCacheKey = 'app_settings';
  static const Duration cacheExpiration = Duration(minutes: 30);

  // API constants
  static const int apiTimeout = 30; // seconds
  static const int maxRetries = 3;
}

/// App colors for theming
class AppColors {
  // Primary colors
  static const primaryBlue = Colors.blue;
  static const secondaryBlue = Colors.lightBlue;
  static const accentBlue = Colors.indigo;

  // Weather condition colors
  static const sunnyYellow = Colors.amber;
  static const cloudyGrey = Colors.blueGrey;
  static const rainyBlue = Colors.blue;
  static const snowyLightBlue = Colors.lightBlue;
  static const stormyPurple = Colors.deepPurple;

  // UI colors
  static const backgroundLight = Color(0xFFF5F5F5);
  static const backgroundDark = Color(0xFF121212);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF1E1E1E);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textLight = Color(0xFFFFFFFF);
  static const errorRed = Color(0xFFE57373);
  static const successGreen = Color(0xFF81C784);
}
