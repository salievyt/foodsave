import 'package:flutter/material.dart';

/// Дизайн-система: Отступы и размеры
class AppSpacing {
  AppSpacing._();
  
  /// 4px
  static const double xs = 4.0;
  
  /// 8px
  static const double sm = 8.0;
  
  /// 12px
  static const double md = 12.0;
  
  /// 16px
  static const double lg = 16.0;
  
  /// 20px
  static const double xl = 20.0;
  
  /// 24px
  static const double xxl = 24.0;
  
  /// 32px
  static const double xxxl = 32.0;
  
  /// 48px
  static const double huge = 48.0;

  // ========== Padding ==========
  
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);

  // ========== Border Radius ==========
  
  /// 8px - маленькие элементы
  static const double radiusSm = 8.0;
  
  /// 12px - кнопки, поля ввода
  static const double radiusMd = 12.0;
  
  /// 16px - карточки
  static const double radiusLg = 16.0;
  
  /// 24px - большие карточки
  static const double radiusXl = 24.0;
  
  /// 32px - секции
  static const double radiusXxl = 32.0;
  
  /// Полная закруглённость (круглые кнопки)
  static const double radiusFull = 100.0;

  // ========== BorderRadius объекты ==========
  
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusXxl = BorderRadius.circular(radiusXxl);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(radiusFull);

  // ========== Размеры компонентов ==========
  
  /// Высота кнопки
  static const double buttonHeight = 52.0;
  
  /// Высота маленькой кнопки
  static const double buttonHeightSm = 40.0;
  
  /// Высота поля ввода
  static const double inputHeight = 52.0;
  
  /// Высота AppBar
  static const double appBarHeight = 56.0;
  
  /// Высота Bottom Navigation
  static const double bottomNavHeight = 80.0;
  
  /// Размер иконки
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // ========== Тени ==========
  
  static List<BoxShadow> get shadowSm => [
    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
  ];
  
  static List<BoxShadow> get shadowMd => [
    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6)),
  ];
  
  static List<BoxShadow> get shadowLg => [
    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
  ];
  
  static List<BoxShadow> get shadowPrimary => [
    BoxShadow(color: const Color(0xFFE53935).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
  ];

  // ========== Анимации ==========
  
  /// Длительность короткой анимации
  static const Duration animFast = Duration(milliseconds: 150);
  
  /// Длительность стандартной анимации
  static const Duration animNormal = Duration(milliseconds: 300);
  
  /// Длительность длинной анимации
  static const Duration animSlow = Duration(milliseconds: 500);
  
  /// Кривая для стандартных анимаций
  static const Curve animCurve = Curves.easeInOut;
  
  /// Кривая для bounce-эффекта
  static const Curve animCurveBounce = Curves.elasticOut;
}
