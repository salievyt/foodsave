import 'package:flutter/material.dart';
import 'package:food_save/core/theme/app_colors.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onAction,
          child: Text(
            action,
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
