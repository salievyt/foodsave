import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/core/router/app_router.gr.dart';

class ScanActionCard extends StatelessWidget {
  const ScanActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          child: Ink(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFFFF6B6B)],
              ),
            ),
            child: InkWell(
              onTap: () => context.navigateTo(const ScannerRoute()),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.qr_code_scanner_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Сканер чеков",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                        Text("Добавь продукты за секунду",
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AIRecipeCard extends StatelessWidget {
  const AIRecipeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.navigateTo(const RecipesRoute()),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    AppColors.accent.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text("🥘", style: TextStyle(fontSize: 70)),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "AI ПОДБОР",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Кулинарные идеи",
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                            "Что можно приготовить из продуктов,\nкоторые уже есть в наличии?",
                            style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                                fontSize: 13,
                                height: 1.4)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 24, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
