import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/features/fridge/domain/models/product.dart';
import 'package:food_save/features/fridge/presentation/controllers/fridge_controller.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/features/profile/presentation/controllers/profile_controller.dart';
import 'package:food_save/core/widgets/base_page.dart';

// New extracted widgets
import '../widgets/bento_grid.dart';
import '../widgets/expiring_products_list.dart';
import '../widgets/home_action_cards.dart';

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
    final activeProducts =
        products.where((p) => !p.isEaten && !p.isSpoiled).toList();

    final int freshCount = activeProducts
        .where((p) => p.freshnessStatus == FreshnessStatus.fresh)
        .length;
    final int soonCount = activeProducts
        .where((p) => p.freshnessStatus == FreshnessStatus.soon)
        .length;
    final int urgentCount = activeProducts
        .where((p) =>
            p.freshnessStatus == FreshnessStatus.urgent ||
            p.freshnessStatus == FreshnessStatus.spoiled)
        .length;

    final double fillPercentage =
        activeProducts.length > 20 ? 1.0 : activeProducts.length / 20.0;

    final urgentProducts = activeProducts
        .where((p) =>
            p.freshnessStatus == FreshnessStatus.urgent ||
            p.freshnessStatus == FreshnessStatus.soon)
        .toList();

    final controller = ref.read(fridgeControllerProvider.notifier);
    final eaten = controller.totalEaten;
    final spoiled = controller.totalSpoiled;

    final theme = Theme.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(context, ref, theme),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(ref, theme),
                const SizedBox(height: 24),

                // Bento Grid
                BentoGrid(
                  fillPercentage: fillPercentage,
                  fresh: freshCount,
                  soon: soonCount,
                  urgent: urgentCount,
                  eaten: eaten,
                  spoiled: spoiled,
                ),

                const SizedBox(height: 32),
                _buildSectionHeader(
                  context,
                  title: "Заканчивается срок",
                  onTap: () => context.navigateTo(const FridgeRoute()),
                ),
                const SizedBox(height: 16),
                ExpiringProductsList(products: urgentProducts),

                const SizedBox(height: 32),
                const ScanActionCard(),

                const SizedBox(height: 32),
                _buildSectionHeader(
                  context,
                  title: "Что приготовить?",
                  onTap: () => context.navigateTo(const RecipesRoute()),
                ),
                const SizedBox(height: 16),
                const AIRecipeCard(),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, WidgetRef ref, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 80,
      collapsedHeight: 60,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            titlePadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            centerTitle: false,
            title: Row(
              children: [
                const Text(
                  "FoodSave",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -1,
                  ),
                ),
                const Spacer(),
                _buildAvatar(ref, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(WidgetRef ref, ThemeData theme) {
    final profileState = ref.watch(userProfileProvider);
    final String name = profileState.data?.username.split(' ').first ?? "Друг";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Привет, $name! 👋",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Давай посмотрим, что в холодильнике.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(WidgetRef ref, ThemeData theme) {
    final profileState = ref.watch(userProfileProvider);
    if (profileState.isLoading) {
      return const SizedBox(
        width: 38,
        height: 38,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (profileState.error != null) {
      return const Icon(Icons.error_outline);
    }

    final profile = profileState.data;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
        ],
        image: profile?.avatarUrl != null
            ? DecorationImage(
                image: NetworkImage(profile!.avatarUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: profile?.avatarUrl == null
          ? const Icon(Icons.person_rounded, size: 20, color: AppColors.primary)
          : null,
    );
  }

  Widget _buildSectionHeader(BuildContext context,
      {required String title, VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                )),
        if (onTap != null)
          TextButton(
              onPressed: onTap,
              child: const Row(
                children: [
                  Text("Все",
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800)),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.primary, size: 20),
                ],
              )),
      ],
    );
  }
}
