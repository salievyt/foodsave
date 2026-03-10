import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/core/theme/app_colors.dart';
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
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            HomeBrandHeader(onAvatarTap: () => context.navigateTo(const ProfileRoute())),
            const SizedBox(height: 16),
            HomeStatsStrip(
              totalActive: activeProducts.length,
              urgent: urgentCount,
              soon: soonCount,
              saved: eaten,
            ),
            const SizedBox(height: 16),
            HomeActionBar(
              onScan: () => context.navigateTo(const ScannerRoute()),
              onOpenFridge: () => context.navigateTo(const FridgeRoute()),
            ),
            const SizedBox(height: 18),
            HomeSectionHeader(
              title: "Ближайший срок",
              action: "Холодильник",
              onAction: () => context.navigateTo(const FridgeRoute()),
            ),
            const SizedBox(height: 8),
            HomeUrgentList(items: urgentProducts),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.6)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Подберите рецепт по продуктам в холодильнике.",
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.navigateTo(const RecipesRoute()),
                    child: const Text("К рецептам"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
