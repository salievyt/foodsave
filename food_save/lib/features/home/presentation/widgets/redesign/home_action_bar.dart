import 'package:flutter/material.dart';
import 'package:food_save/core/theme/app_colors.dart';

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
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
        const SizedBox(width: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: theme.dividerColor.withOpacity(0.6)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onPressed: onOpenFridge,
          child: const Text(
            "Холодильник",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
