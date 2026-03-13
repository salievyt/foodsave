import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/features/fridge/presentation/controllers/fridge_controller.dart';
import 'package:food_save/features/recipes/presentation/viewmodels/recipes_view_model.dart';
import 'package:food_save/core/utils/responsive.dart';

@RoutePage()
class RecipeDetailPage extends ConsumerStatefulWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends ConsumerState<RecipeDetailPage> {
  late List<bool> _completedSteps;

  @override
  void initState() {
    super.initState();
    _completedSteps = List.filled(widget.recipe.steps.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final isFav = ref.watch(favoriteRecipesProvider).any((r) => r.id == recipe.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              onPressed: () => context.router.maybePop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ref.read(favoriteRecipesProvider.notifier).toggleFavorite(recipe);
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(recipe.emoji, style: const TextStyle(fontSize: 80)),
                      const SizedBox(height: 8),
                      if (recipe.matchPercent > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${recipe.matchPercent.toInt()}% совпадение',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.hPadding(context),
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (recipe.description != null && recipe.description!.isNotEmpty) ...[
                    Text(
                      recipe.description!,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tags row
                  Row(
                    children: [
                      _infoChip(Icons.timer_outlined, recipe.time ?? '30 мин'),
                      const SizedBox(width: 10),
                      _infoChip(Icons.bar_chart_rounded, recipe.difficulty ?? 'Средне'),
                      if (recipe.calories != null) ...[
                        const SizedBox(width: 10),
                        _infoChip(Icons.local_fire_department_rounded, '${recipe.calories} ккал'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Ingredients
                  const Text(
                    'Ингредиенты',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 12),
                  ...recipe.ingredients.map((ing) => _ingredientRow(ing)),
                  const SizedBox(height: 28),

                  // Steps
                  if (recipe.steps.isNotEmpty) ...[
                    const Text(
                      'Пошаговый рецепт',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 16),
                    ...recipe.steps.asMap().entries.map((entry) => _stepCard(entry.key, entry.value)),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Пошаговые инструкции появятся в следующем обновлении',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Cook button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        for (final ingredient in recipe.ingredients) {
                          ref.read(fridgeControllerProvider.notifier).markAsEatenByName(ingredient);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Готово! Ингредиенты для "${recipe.title}" списаны.'),
                            backgroundColor: AppColors.fresh,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        context.router.maybePop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text('Готовлю!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _ingredientRow(String name) {
    final products = ref.watch(fridgeControllerProvider);
    final hasInFridge = products.any(
      (p) => !p.isEaten && !p.isSpoiled && 
        (p.name.toLowerCase().contains(name.toLowerCase()) || name.toLowerCase().contains(p.name.toLowerCase())),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: hasInFridge
              ? Border.all(color: AppColors.fresh.withValues(alpha: 0.4), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              hasInFridge ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: hasInFridge ? AppColors.fresh : AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: hasInFridge ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
            if (hasInFridge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.fresh.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Есть', style: TextStyle(color: AppColors.fresh, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stepCard(int index, RecipeStep step) {
    final isCompleted = _completedSteps[index];
    return GestureDetector(
      onTap: () => setState(() => _completedSteps[index] = !_completedSteps[index]),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.fresh.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isCompleted ? Border.all(color: AppColors.fresh.withValues(alpha: 0.3)) : null,
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.fresh : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                step.instruction,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
