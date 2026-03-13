import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/core/theme/theme.dart';
import 'package:food_save/core/widgets/base_page.dart';
import 'package:food_save/features/fridge/domain/models/product.dart';
import 'package:food_save/features/fridge/presentation/controllers/fridge_controller.dart';

import '../widgets/redesign/home_action_bar.dart';
import '../widgets/redesign/home_brand_header.dart';
import '../widgets/redesign/home_section_header.dart';
import '../widgets/redesign/home_stats_strip.dart';
import '../widgets/redesign/home_urgent_list.dart';

@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _HomePageContent(ref: ref);
  }
}

class _HomePageContent extends BasePage {
  final WidgetRef ref;

  const _HomePageContent({required this.ref});

  @override
  Widget buildBody(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final products = ref.watch(fridgeControllerProvider);
    final activeProducts = products.where((p) => !p.isEaten && !p.isSpoiled).toList();

    final int soonCount = activeProducts
        .where((p) => p.freshnessStatus == FreshnessStatus.soon)
        .length;
    final int urgentCount = activeProducts
        .where((p) =>
            p.freshnessStatus == FreshnessStatus.urgent ||
            p.freshnessStatus == FreshnessStatus.spoiled)
        .length;

    final urgentProducts = activeProducts
        .where((p) =>
            p.freshnessStatus == FreshnessStatus.urgent ||
            p.freshnessStatus == FreshnessStatus.soon)
        .toList();

    final controller = ref.read(fridgeControllerProvider.notifier);
    final eaten = controller.totalEaten;

    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          children: [
            HomeBrandHeader(onAvatarTap: () => context.navigateTo(const ProfileRoute())),
            const SizedBox(height: AppSpacing.md),
            HomeStatsStrip(
              totalActive: activeProducts.length,
              urgent: urgentCount,
              soon: soonCount,
              saved: eaten,
            ),
            const SizedBox(height: AppSpacing.md),
            HomeActionBar(
              onScan: () => context.navigateTo(const ScannerRoute()),
              onOpenFridge: () => context.navigateTo(const FridgeRoute()),
            ),
            const SizedBox(height: AppSpacing.md + 2),
            HomeSectionHeader(
              title: "Ближайший срок",
              action: "Холодильник",
              onAction: () => context.navigateTo(const FridgeRoute()),
            ),
            const SizedBox(height: AppSpacing.sm),
            HomeUrgentList(items: urgentProducts),
            const SizedBox(height: AppSpacing.xxl),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: Text(
                      "Подберите рецепт по продуктам в холодильнике.",
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.navigateTo(const RecipesRoute()),
                    child: const Text("К рецептам"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
