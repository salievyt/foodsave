import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:food_save/core/theme/app_colors.dart';

class GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final bool isActive;

  const GlassButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size * 0.45,
            ),
          ),
        ),
      ),
    );
  }
}

class ScannerTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onFlashToggle;
  final bool isFlashOn;

  const ScannerTopBar({
    super.key,
    required this.onBack,
    required this.onFlashToggle,
    required this.isFlashOn,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: onBack,
          ),
          const Text(
            "Сканирование",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          GlassButton(
            icon: isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            onPressed: onFlashToggle,
            isActive: isFlashOn,
          ),
        ],
      ),
    );
  }
}

class ScannerBottomPanel extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onManualInput;
  final VoidCallback onCapture;

  const ScannerBottomPanel({
    super.key,
    required this.isProcessing,
    required this.onManualInput,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            30, 20, 30, MediaQuery.of(context).padding.bottom + 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.6),
              Colors.black.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  icon: Icons.edit_note_rounded,
                  label: "Вручную",
                  onTap: onManualInput,
                ),
                _buildCaptureButton(onCapture, isProcessing),
                _buildActionButton(
                  icon: Icons.history_rounded,
                  label: "История",
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              isProcessing
                  ? "Распознавание продуктов..."
                  : "Поместите чек в рамку",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GlassButton(icon: icon, onPressed: onTap),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureButton(VoidCallback onTap, bool isProcessing) {
    return GestureDetector(
      onTap: isProcessing ? null : onTap,
      child: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isProcessing ? Colors.grey : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              if (!isProcessing)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
            ],
          ),
          child: isProcessing
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                )
              : const Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary, size: 32),
        ),
      ),
    );
  }
}
