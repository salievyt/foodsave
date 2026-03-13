import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Дизайн-система: Типографика
class AppTypography {
  AppTypography._();

  // ========== Заголовки (Headlines) ==========
  
  static TextStyle h1(BuildContext context) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    height: 1.2,
    color: _textColor(context),
  );

  static TextStyle h2(BuildContext context) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
    color: _textColor(context),
  );

  static TextStyle h3(BuildContext context) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.3,
    color: _textColor(context),
  );

  static TextStyle h4(BuildContext context) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.35,
    color: _textColor(context),
  );

  static TextStyle h5(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
    color: _textColor(context),
  );

  // ========== Основной текст (Body) ==========
  
  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: _textColor(context),
  );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: _textColor(context),
  );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: _secondaryTextColor(context),
  );

  // ========== Лейблы (Labels) ==========
  
  static TextStyle labelLarge(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: _textColor(context),
  );

  static TextStyle labelMedium(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
    color: _textColor(context),
  );

  static TextStyle labelSmall(BuildContext context) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
    color: _secondaryTextColor(context),
  );

  // ========== Специальные стили ==========
  
  /// Цена
  static TextStyle price(BuildContext context) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.primary,
  );

  /// Скидка
  static TextStyle discount(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    backgroundColor: AppColors.primary,
  );

  /// Количество (в кружках)
  static TextStyle badge(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ========== Вспомогательные методы ==========
  
  static Color _textColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  }

  static Color _secondaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  }
}

/// Расширение для TextStyle с быстрым доступом
extension AppTextStyles on BuildContext {
  TextStyle get textH1 => AppTypography.h1(this);
  TextStyle get textH2 => AppTypography.h2(this);
  TextStyle get textH3 => AppTypography.h3(this);
  TextStyle get textH4 => AppTypography.h4(this);
  TextStyle get textH5 => AppTypography.h5(this);
  TextStyle get textBodyLarge => AppTypography.bodyLarge(this);
  TextStyle get textBodyMedium => AppTypography.bodyMedium(this);
  TextStyle get textBodySmall => AppTypography.bodySmall(this);
  TextStyle get textLabelLarge => AppTypography.labelLarge(this);
  TextStyle get textLabelMedium => AppTypography.labelMedium(this);
  TextStyle get textLabelSmall => AppTypography.labelSmall(this);
  TextStyle get textPrice => AppTypography.price(this);
  TextStyle get textDiscount => AppTypography.discount(this);
  TextStyle get textBadge => AppTypography.badge(this);
}
