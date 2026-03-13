import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Дизайн-система: Haptic Feedback (виброотклик)
class AppHaptics {
  AppHaptics._();

  // ========== Типы виброотклика ==========
  
  /// Лёгкое касание - для нажатий на small элементы
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Среднее касание - для кнопок и стандартных действий
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Сильное касание - для важных действий
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Вибрация selection - для переключения (switch, checkbox)
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Успех - для успешных действий
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }

  /// Ошибка - для ошибок
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  /// Копирование - для копирования текста
  static Future<void> copy() async {
    await HapticFeedback.lightImpact();
  }
}

/// Виджет-обёртка для автоматического haptic при нажатии
class HapticTouchable extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableHaptic;

  const HapticTouchable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enableHaptic ? () {
        AppHaptics.light();
        onTap?.call();
      } : onTap,
      onLongPress: enableHaptic ? () {
        AppHaptics.medium();
        onLongPress?.call();
      } : onLongPress,
      child: child,
    );
  }
}

/// Анимированная кнопка с haptic
class HapticButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool enableHaptic;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const HapticButton({
    super.key,
    required this.child,
    this.onPressed,
    this.enableHaptic = true,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
  });

  @override
  State<HapticButton> createState() => _HapticButtonState();
}

class _HapticButtonState extends State<HapticButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    if (widget.enableHaptic) {
      AppHaptics.light();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: widget.borderRadius,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
