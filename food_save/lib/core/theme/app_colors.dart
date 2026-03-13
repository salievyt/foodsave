import 'package:flutter/material.dart';

/// Дизайн-система: Цвета
/// Красная цветовая схема для FoodSave
class AppColors {
  AppColors._();

  // ========== Основные цвета ==========
  
  /// Главный цвет (красный) - #E53935
  static const Color primary = Color(0xFFE53935);
  
  /// Тёмная версия для нажатий - #B71C1C  
  static const Color primaryDark = Color(0xFFB71C1C);
  
  /// Светлая версия для фонов - #FFCDD2
  static const Color primaryLight = Color(0xFFFFCDD2);
  
  /// Акцентный оранжевый - #FF9800
  static const Color accent = Color(0xFFFF9800);
  
  /// Премиум золотой - #FFD700
  static const Color premium = Color(0xFFFFD700);

  // ========== Статусы свежести ==========
  
  /// Свежий (зелёный) - #4CAF50
  static const Color fresh = Color(0xFF4CAF50);

  /// Скоро истекает (жёлтый) - #FFC107
  static const Color warning = Color(0xFFFFC107);
  
  /// Срочно (оранжевый) - #FF9800
  static const Color urgent = Color(0xFFFF9800);
  
  /// Просрочен (красный) - #F44336
  static const Color error = Color(0xFFF44336);

  // ========== Светлая тема ==========
  
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF2F2F7);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFC7C7CC);
  static const Color border = Color(0xFFE5E5EA);
  static const Color shadow = Color(0x0A000000);
  static const Color divider = Color(0xFFE5E5EA);

  // ========== Тёмная тема ==========
  
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2E);
  static const Color darkTextPrimary = Color(0xFFE5E5EA);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  static const Color darkTextTertiary = Color(0xFF48484A);
  static const Color darkBorder = Color(0xFF38383A);
  static const Color darkShadow = Color(0x33000000);
  static const Color darkDivider = Color(0xFF38383A);

  // ========== Градиенты ==========
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient freshGradient = LinearGradient(
    colors: [fresh, Color(0xFF62D2A2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
