import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/features/fridge/domain/models/product.dart';
import 'package:food_save/features/fridge/presentation/controllers/fridge_controller.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/features/profile/presentation/controllers/profile_controller.dart';

@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(fridgeControllerProvider);
    final activeProducts = products.where((p) => !p.isEaten && !p.isSpoiled).toList();
    
    final int freshCount = activeProducts.where((p) => p.freshnessStatus == FreshnessStatus.fresh).length;
    final int soonCount = activeProducts.where((p) => p.freshnessStatus == FreshnessStatus.soon).length;
    final int urgentCount = activeProducts.where((p) => p.freshnessStatus == FreshnessStatus.urgent || p.freshnessStatus == FreshnessStatus.spoiled).length;
    
    final double fillPercentage = activeProducts.length > 20 ? 1.0 : activeProducts.length / 20.0;

    final urgentProducts = activeProducts.where(
      (p) => p.freshnessStatus == FreshnessStatus.urgent || p.freshnessStatus == FreshnessStatus.soon
    ).toList();

    final controller = ref.read(fridgeControllerProvider.notifier);
    final eaten = controller.totalEaten;
    final spoiled = controller.totalSpoiled;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
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
                  _buildBentoGrid(context, fillPercentage, freshCount, soonCount, urgentCount, eaten, spoiled, theme, isDark),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    context,
                    title: "Заканчивается срок", 
                    onTap: () => context.navigateTo(const FridgeRoute()),
                  ),
                  const SizedBox(height: 16),
                  _buildExpiringHorizontalList(urgentProducts, theme, isDark),
                  
                  const SizedBox(height: 32),
                  _buildScanAction(context, theme, isDark),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    context,
                    title: "Что приготовить?", 
                    onTap: () => context.navigateTo(const RecipesRoute()),
                  ),
                  const SizedBox(height: 16),
                  _buildAIRecipeCard(context, theme, isDark),
                  
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 80,
      collapsedHeight: 60,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
    final profileAsync = ref.watch(userProfileProvider);
    final String name = profileAsync.maybeWhen(
      data: (p) => p.username.split(' ').first,
      orElse: () => "Друг",
    );

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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(
    BuildContext context, 
    double fillPercentage, int fresh, int soon, int urgent,
    int eaten, int spoiled,
    ThemeData theme, bool isDark
  ) {
    return Column(
      children: [
        // Large status card
        GestureDetector(
          onTap: () => context.navigateTo(const StatisticsRoute()),
          child: _buildMainStatusCard(fillPercentage, fresh, soon, urgent, theme, isDark),
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

  Widget _buildMainStatusCard(double fillPercentage, int fresh, int soon, int urgent, ThemeData theme, bool isDark) {
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
                _buildIndicatorRow(fresh, soon, urgent, theme),
              ],
            ),
          ),
          _buildCircularProgress(fillPercentage, theme),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow(int fresh, int soon, int urgent, ThemeData theme) {
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
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
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

  Widget _buildCircularProgress(double value, ThemeData theme) {
    return Container(
      width: 100, height: 100,
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
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.5)],
            ).createShader(rect),
            child: CircularProgressIndicator(
              value: value, 
              strokeWidth: 10, 
              backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              strokeCap: StrokeCap.round,
            ),
          ),
          const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 32),
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

  Widget _buildExpiringHorizontalList(List<Product> products, ThemeData theme, bool isDark) {
    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E).withValues(alpha: 0.5) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            const Text("🎉", style: TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              "Всё свежее! Ничего не пропадает.",
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final color = product.freshnessStatus == FreshnessStatus.urgent ? AppColors.primary : AppColors.warning;

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 8))
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'product_${product.id}',
                  child: Text(product.emoji, style: const TextStyle(fontSize: 40))
                ),
                const Spacer(),
                Text(
                  product.name, 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.5)
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                     product.daysLeft <= 0 ? "Срочно" : "${product.daysLeft} дн. осталось",
                     style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)
                   ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScanAction(BuildContext context, ThemeData theme, bool isDark) {
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
                      child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Сканер чеков", 
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)
                        ),
                        Text(
                          "Добавь продукты за секунду", 
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIRecipeCard(BuildContext context, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () => context.navigateTo(const RecipesRoute()),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 20, offset: const Offset(0, 10))],
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
                    top: 16, right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "AI ПОДБОР",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
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
                        Text(
                          "Кулинарные идеи", 
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Что можно приготовить из продуктов,\nкоторые уже есть в наличии?", 
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13, height: 1.4)
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 24, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(WidgetRef ref, ThemeData theme) {
    final profileAsync = ref.watch(userProfileProvider);
    return profileAsync.when(
      data: (profile) => Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
          image: profile.avatarUrl != null 
            ? DecorationImage(image: NetworkImage(profile.avatarUrl!), fit: BoxFit.cover)
            : null,
        ),
        child: profile.avatarUrl == null 
          ? const Icon(Icons.person_rounded, size: 20, color: AppColors.primary)
          : null,
      ),
      loading: () => const SizedBox(width: 38, height: 38, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => const Icon(Icons.error_outline),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title, 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          )
        ),
        if (onTap != null)
           TextButton(
            onPressed: onTap, 
            child: Row(
              children: const [
                Text("Все", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 20),
              ],
            )
          ),
      ],
    );
  }
}