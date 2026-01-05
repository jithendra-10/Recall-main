import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Updated for Settings Screen
  static const primary = Color(0xFF00E5FF);    // Cyan
  static const secondary = Color(0xFF2979FF);  // Blue
  
  // Backgrounds
  static const backgroundDark = Color(0xFF21262C);
  static const surfaceDark = Color(0xFF2C333A);
  
  // Text
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF9CA3AF); // Gray-400
  
  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const cardGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
