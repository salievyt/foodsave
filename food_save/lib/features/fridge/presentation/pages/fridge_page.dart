import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/core/widgets/base_page.dart';
import 'package:food_save/features/fridge/presentation/viewmodels/fridge_view_model.dart';
import 'package:food_save/features/fridge/presentation/widgets/add_product_sheet.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/core/utils/responsive.dart';
import '../widgets/product_list_item.dart';

@RoutePage()
class FridgePage extends ConsumerWidget {
  const FridgePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _FridgePageContent(ref: ref);
  }
}

class _FridgePageContent extends BasePage {
  final WidgetRef ref;
  const _FridgePageContent({required this.ref});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      toolbarHeight: 0,
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final activeProducts = ref.watch(filteredFridgeProvider);
    final theme = Theme.of(context);
    final h = Responsive.hPadding(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 140,
          collapsedHeight: 80,
          floating: true,
          pinned: true,
          elevation: 0,
          // ignore: deprecated_member_use
          backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.8),
          flexibleSpace: FlexibleSpaceBar(
            background: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
            titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: Text(
              "Твой Холодильник",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _showAddProduct(context),
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 30),
              tooltip: 'Добавить вручную',
            ),
            IconButton(
              onPressed: () => context.navigateTo(const ScannerRoute()),
              icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textSecondary, size: 26),
              tooltip: 'Сканировать чек',
            ),
            const SizedBox(width: 8),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(h, 0, h, 20),
            child: _buildSearchBar(context, ref),
          ),
        ),

        SliverPersistentHeader(
          pinned: true,
          delegate: _CategoryHeaderDelegate(ref),
        ),

        if (activeProducts.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyFridgeView(),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: h, vertical: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ProductListItem(product: activeProducts[index]),
                childCount: activeProducts.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  void _showAddProduct(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddProductSheet(),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        onChanged: (val) => ref.read(fridgeSearchProvider.notifier).update(val),
        decoration: const InputDecoration(
          hintText: "Поиск продуктов...",
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _EmptyFridgeView extends StatelessWidget {
  const _EmptyFridgeView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Холодильник пока пуст",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            "Нажмите + чтобы добавить продукт",
            style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final WidgetRef ref;
  _CategoryHeaderDelegate(this.ref);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final selectedCategory = ref.watch(fridgeCategoryProvider);
    final categories = ['Все', 'Мясо', 'Молочка', 'Овощи', 'Фрукты', 'Напитки', 'Другое'];
    final h = Responsive.hPadding(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: h, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return _categoryChip(context, cat, selectedCategory == cat);
        },
      ),
    );
  }

  Widget _categoryChip(BuildContext context, String title, bool isSelected) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => ref.read(fridgeCategoryProvider.notifier).update(title),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                // ignore: deprecated_member_use
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
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
