import 'package:flutter/material.dart';
import 'package:food_save/core/theme/app_colors.dart';

class ProfileGuestBadge extends StatelessWidget {
  final String label;

  const ProfileGuestBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primary, fontSize: 12),
      ),
    );
  }
}
