import 'package:flutter/services.dart';


class HapticsService {
  HapticsService._();

  /// Лёгкий виброотклик - для нажатий
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Средний виброотклик - для важных действий
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Сильный виброотклик - для критических действий
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Вибрация при выборе (selection click)
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Успех - специальный паттерн
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Ошибка - специальный паттерн
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Предупреждение
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
  }
}

/// Миксин для виджетов с виброоткликом
mixin HapticsMixin {
  void onTapHaptic() => HapticsService.lightImpact();
  void onLongPressHaptic() => HapticsService.mediumImpact();
  void onSubmitHaptic() => HapticsService.mediumImpact();
}
