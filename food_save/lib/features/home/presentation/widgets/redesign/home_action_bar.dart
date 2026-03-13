import 'package:flutter/material.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/core/theme/app_spacing.dart';

class HomeActionBar extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onOpenFridge;

  const HomeActionBar({
    super.key,
    required this.onScan,
    required this.onOpenFridge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onScan,
            child: const Text(
              "Сканировать чек",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.dividerColor.withOpacity(0.6)),
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onOpenFridge,
            child: const Text(
              "Холодильник",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
