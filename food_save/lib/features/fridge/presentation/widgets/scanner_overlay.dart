import 'package:flutter/material.dart';
import 'package:food_save/core/theme/app_colors.dart';

class ScanOverlay extends StatelessWidget {
  final double scanFrameWidth;
  final double scanFrameHeight;
  final double borderRadius;

  const ScanOverlay({
    super.key,
    required this.scanFrameWidth,
    required this.scanFrameHeight,
    this.borderRadius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ScanOverlayPainter(
        scanFrameWidth: scanFrameWidth,
        scanFrameHeight: scanFrameHeight,
        borderRadius: borderRadius,
      ),
    );
  }
}

class ScanFrameCorners extends StatelessWidget {
  const ScanFrameCorners({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildCorner(Alignment.topLeft),
        _buildCorner(Alignment.topRight),
        _buildCorner(Alignment.bottomLeft),
        _buildCorner(Alignment.bottomRight),
      ],
    );
  }

  Widget _buildCorner(Alignment alignment) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    const cornerSize = 32.0;
    const thickness = 4.0;
    const radius = 12.0;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: cornerSize,
        height: cornerSize,
        child: CustomPaint(
          painter: _CornerPainter(
            isTop: isTop,
            isLeft: isLeft,
            color: AppColors.primary,
            thickness: thickness,
            radius: radius,
          ),
        ),
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  final double scanFrameWidth;
  final double scanFrameHeight;
  final double borderRadius;

  _ScanOverlayPainter({
    required this.scanFrameWidth,
    required this.scanFrameHeight,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);

    final frameLeft = (size.width - scanFrameWidth) / 2;
    final frameTop = (size.height - scanFrameHeight) / 2 - 20;

    final outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final innerPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(frameLeft, frameTop, scanFrameWidth, scanFrameHeight),
        Radius.circular(borderRadius),
      ));

    final overlayPath =
        Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) =>
      oldDelegate.scanFrameWidth != scanFrameWidth ||
      oldDelegate.scanFrameHeight != scanFrameHeight;
}

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final Color color;
  final double thickness;
  final double radius;

  _CornerPainter({
    required this.isTop,
    required this.isLeft,
    required this.color,
    required this.thickness,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(size.width, size.height);
      path.lineTo(size.width, radius);
      path.quadraticBezierTo(size.width, 0, size.width - radius, 0);
      path.lineTo(0, 0);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height - radius);
      path.quadraticBezierTo(0, size.height, radius, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(
          size.width, size.height, size.width - radius, size.height);
      path.lineTo(0, size.height);
    }

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = thickness + 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => false;
}
