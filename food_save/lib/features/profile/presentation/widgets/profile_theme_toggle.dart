import 'package:flutter/material.dart';
import 'package:food_save/core/theme/app_colors.dart';

class ProfileThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const ProfileThemeToggle({
    super.key,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Тема",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Switch.adaptive(
            value: isDark,
            onChanged: (_) => onToggle(),
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
