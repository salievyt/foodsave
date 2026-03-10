import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/core/router/app_router.gr.dart';

class BentoGrid extends StatelessWidget {
  final double fillPercentage;
  final int fresh;
  final int soon;
  final int urgent;
  final int eaten;
  final int spoiled;

  const BentoGrid({
    super.key,
    required this.fillPercentage,
    required this.fresh,
    required this.soon,
    required this.urgent,
    required this.eaten,
    required this.spoiled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Large status card
        GestureDetector(
          onTap: () => context.navigateTo(const StatisticsRoute()),
          child: _buildMainStatusCard(theme, isDark),
        ),
        const SizedBox(height: 16),
        // Two small cards
        Row(
          children: [
            Expanded(
              child: _buildMiniBentoCard(
                title: "Съедено",
                value: "$eaten",
                icon: Icons.check_circle_rounded,
                color: AppColors.fresh,
                theme: theme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMiniBentoCard(
                title: "Испортилось",
                value: "$spoiled",
                icon: Icons.delete_outline_rounded,
                color: AppColors.primary.withValues(alpha: 0.7),
                theme: theme,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainStatusCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)]
              : [Colors.white, const Color(0xFFF2F2F7)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Заполненность",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${(fillPercentage * 100).toInt()}%",
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _buildIndicatorRow(theme),
              ],
            ),
          ),
          _buildCircularProgress(theme),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow(ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        if (urgent > 0) _indicatorDot(AppColors.primary, "$urgent", theme),
        if (soon > 0) _indicatorDot(AppColors.warning, "$soon", theme),
        _indicatorDot(AppColors.fresh, "$fresh", theme),
      ],
    );
  }

  Widget _indicatorDot(Color color, String count, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(ThemeData theme) {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.5)
              ],
            ).createShader(rect),
            child: CircularProgressIndicator(
              value: fillPercentage,
              strokeWidth: 10,
              backgroundColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.05),
              strokeCap: StrokeCap.round,
            ),
          ),
          const Icon(Icons.inventory_2_rounded,
              color: AppColors.primary, size: 32),
        ],
      ),
    );
  }

  Widget _buildMiniBentoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
