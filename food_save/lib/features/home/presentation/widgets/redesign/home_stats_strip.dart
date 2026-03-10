import 'package:flutter/material.dart';
import 'package:food_save/core/theme/app_colors.dart';

class HomeStatsStrip extends StatelessWidget {
  final int totalActive;
  final int urgent;
  final int soon;
  final int saved;

  const HomeStatsStrip({
    super.key,
    required this.totalActive,
    required this.urgent,
    required this.soon,
    required this.saved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          _StatItem(label: "В холодильнике", value: totalActive.toString()),
          _divider(theme),
          _StatItem(label: "Срочно", value: urgent.toString(), highlight: true),
          _divider(theme),
          _StatItem(label: "Скоро", value: soon.toString()),
          _divider(theme),
          _StatItem(label: "Спасено", value: saved.toString()),
        ],
      ),
    );
  }

  Widget _divider(ThemeData theme) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: theme.dividerColor.withOpacity(0.6),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatItem({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueColor = highlight ? AppColors.primary : theme.colorScheme.onSurface;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
