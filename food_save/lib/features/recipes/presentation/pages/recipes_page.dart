import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/features/fridge/domain/models/product.dart';
import 'package:food_save/features/fridge/presentation/controllers/fridge_controller.dart';
import 'package:food_save/features/recipes/presentation/controllers/recipes_controller.dart';
import 'package:food_save/core/router/app_router.gr.dart';

@RoutePage()
class RecipesPage extends ConsumerWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(fridgeControllerProvider);

    // Ingredients that are urgent/soon
    final ingredientsToUse = products.where((p) {
      final s = p.freshnessStatus;
      return s == FreshnessStatus.urgent || s == FreshnessStatus.soon;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Sticky header
          SliverAppBar(
            expandedHeight: 180,
            collapsedHeight: 80,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.background.withValues(alpha: 0.8),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderBackground(),
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: const Text(
                "Что приготовить?",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          // Context / Subtitle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Рецепты отсортированы по совпадению с продуктами в вашем холодильнике.",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (ingredientsToUse.isNotEmpty) ...[
                    const Text(
                      "Срочно использовать:",
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ingredientsToUse.map((e) => _buildIngredientChip(e)).toList(),
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.fresh.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.fresh),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Всё свежее! Нет срочных продуктов для спасения.",
                              style: TextStyle(color: AppColors.fresh, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Smart filtered recipes
          ref.watch(filteredRecipesProvider).when(
            data: (recipes) {
              if (recipes.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text("Рецептов пока нет 😢")),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recipe = recipes[index];
                      return _buildRecipeCard(
                        context,
                        ref,
                        recipe: recipe,
                      );
                    },
                    childCount: recipes.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (e, s) => SliverToBoxAdapter(
              child: Center(child: Text("Ошибка загрузки: $e")),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          top: -30,
          right: -20,
          child: Opacity(
            opacity: 0.05,
            child: Icon(Icons.restaurant_menu_rounded, size: 200, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientChip(Product product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.shadow),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(product.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            product.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(
    BuildContext context,
    WidgetRef ref, {
    required Recipe recipe,
  }) {
    final isFav = ref.watch(favoriteRecipesProvider).any((r) => r.id == recipe.id);
    final matchColor = recipe.matchPercent >= 70
        ? AppColors.fresh
        : recipe.matchPercent >= 30
            ? AppColors.warning
            : AppColors.textSecondary;

    return GestureDetector(
      onTap: () {
        context.router.push(RecipeDetailRoute(recipe: recipe));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji banner
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(recipe.emoji, style: const TextStyle(fontSize: 60)),
                  ),
                  if (recipe.matchPercent > 0)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: matchColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${recipe.matchPercent.toInt()}% совпадение',
                          style: TextStyle(color: matchColor, fontWeight: FontWeight.w700, fontSize: 11),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Теги
                  Row(
                    children: [
                      _buildTag(Icons.timer_outlined, recipe.time ?? '30 мин'),
                      const SizedBox(width: 8),
                      _buildTag(Icons.bar_chart_rounded, recipe.difficulty ?? 'Средне'),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Название
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Ингредиенты
                  Text(
                    "Ингредиенты: ${recipe.ingredients.join(', ')}",
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.router.push(RecipeDetailRoute(recipe: recipe));
                          },
                          icon: const Icon(Icons.menu_book_rounded, size: 18),
                          label: const Text('Подробнее'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(color: AppColors.textPrimary.withValues(alpha: 0.15)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          icon: Icon(isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: AppColors.primary),
                          onPressed: () {
                            ref.read(favoriteRecipesProvider.notifier).toggleFavorite(recipe);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isFav ? 'Удалено из избранного' : 'Рецепт сохранён!')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}