import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/features/fridge/domain/models/product.dart';
import 'package:food_save/features/fridge/presentation/controllers/fridge_controller.dart';
import 'package:food_save/features/fridge/presentation/widgets/add_product_sheet.dart';
import 'package:food_save/core/router/app_router.gr.dart';

@RoutePage()
class FridgePage extends ConsumerWidget {
  const FridgePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProducts = ref.watch(filteredFridgeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Заголовок
          SliverAppBar(
            expandedHeight: 140,
            collapsedHeight: 80,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.background.withValues(alpha: 0.8),
            flexibleSpace: FlexibleSpaceBar(
              background: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: const Text(
                "Твой Холодильник",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const AddProductSheet(),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 30),
                  tooltip: 'Добавить вручную',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    context.navigateTo(const ScannerRoute());
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textSecondary, size: 26),
                  tooltip: 'Сканировать чек',
                ),
              ),
            ],
          ),

          // Поиск
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _buildSearchBar(context, ref),
            ),
          ),

          // Категории
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryHeaderDelegate(ref),
          ),

          // Список продуктов
          activeProducts.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          const Text("🧊", style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            "Холодильник пока пуст",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Нажмите + чтобы добавить продукт",
                            style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = activeProducts[index];
                        return _buildDismissibleProductCard(context, ref, product);
                      },
                      childCount: activeProducts.length,
                    ),
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: TextField(
        onChanged: (val) => ref.read(fridgeSearchProvider.notifier).state = val,
        decoration: const InputDecoration(
          hintText: "Поиск продуктов...",
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDismissibleProductCard(BuildContext context, WidgetRef ref, Product product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(product.id),
        behavior: HitTestBehavior.opaque,
        // Свайп влево — Испорчено
        background: _buildSwipeAction(
          color: AppColors.accent,
          icon: Icons.delete_outline_rounded,
          alignment: Alignment.centerLeft,
          label: "В корзину",
        ),
        // Свайп вправо — Использовано
        secondaryBackground: _buildSwipeAction(
          color: AppColors.fresh,
          icon: Icons.check_circle_outline_rounded,
          alignment: Alignment.centerRight,
          label: "Съедено",
        ),
        confirmDismiss: (direction) async {
          // Выполняем действие
          if (direction == DismissDirection.startToEnd) {
            ref.read(fridgeControllerProvider.notifier).markAsSpoiled(product.id);
          } else {
            ref.read(fridgeControllerProvider.notifier).markAsEaten(product.id);
          }

          final actionText = direction == DismissDirection.startToEnd ? 'выброшен' : 'съеден';

          // Показываем SnackBar с Undo
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} $actionText'),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              action: SnackBarAction(
                label: 'ОТМЕНИТЬ',
                textColor: Colors.white,
                onPressed: () {
                  ref.read(fridgeControllerProvider.notifier).restoreProduct(product);
                },
              ),
            ),
          );

          return true;
        },
        child: _buildProductCard(product),
      ),
    );
  }

  Widget _buildSwipeAction({required Color color, required IconData icon, required Alignment alignment, required String label}) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final status = product.freshnessStatus;
    final isUrgent = status == FreshnessStatus.urgent || status == FreshnessStatus.spoiled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 15, offset: const Offset(0, 8))
        ],
        border: isUrgent ? Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 2) : Border.all(color: Colors.transparent, width: 2),
      ),
      child: Row(
        children: [
          // Emoji
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(child: Text(product.emoji, style: const TextStyle(fontSize: 30))),
          ),
          const SizedBox(width: 16),
          // Инфо о продукте
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  "${product.category} • Куплено ${product.purchaseDate.day}.${product.purchaseDate.month}",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 8),
                _buildFreshnessIndicator(product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreshnessIndicator(Product product) {
    Color statusColor;
    String statusText;
    double progress;

    final days = product.daysLeft;

    switch (product.freshnessStatus) {
      case FreshnessStatus.spoiled:
        statusColor = AppColors.textSecondary;
        statusText = "Испорчено";
        progress = 0.0;
        break;
      case FreshnessStatus.urgent:
        statusColor = AppColors.accent;
        statusText = "Срочно!";
        progress = 0.1;
        break;
      case FreshnessStatus.soon:
        statusColor = AppColors.warning;
        statusText = "Скоро";
        progress = 0.4;
        break;
      case FreshnessStatus.fresh:
        statusColor = AppColors.fresh;
        statusText = "Свежее";
        progress = 1.0;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
            Text(product.freshnessStatus == FreshnessStatus.spoiled ? "Просрочено" : "Осталось дней: $days", style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
      ],
    );
  }
}

// Делегат для прилипающей полосы категорий
class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final WidgetRef ref;
  _CategoryHeaderDelegate(this.ref);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final selectedCategory = ref.watch(fridgeCategoryProvider);
    
    final categories = ['Все', 'Мясо', 'Молочка', 'Овощи', 'Фрукты', 'Напитки', 'Другое'];

    return Container(
      color: AppColors.background,
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return _categoryChip(cat, selectedCategory == cat);
        },
      ),
    );
  }

  Widget _categoryChip(String title, bool isSelected) {
    return GestureDetector(
      onTap: () => ref.read(fridgeCategoryProvider.notifier).state = title,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (isSelected) BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60;
  @override
  double get minExtent => 60;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}