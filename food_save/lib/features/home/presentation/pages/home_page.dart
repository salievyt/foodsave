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
    
    // For circular progress
    final double fillPercentage = activeProducts.length > 20 ? 1.0 : activeProducts.length / 20.0;

    // Get urgent products for horizontal list
    final urgentProducts = activeProducts.where(
      (p) => p.freshnessStatus == FreshnessStatus.urgent || p.freshnessStatus == FreshnessStatus.soon
    ).toList();

    // Stats
    final controller = ref.read(fridgeControllerProvider.notifier);
    final eaten = controller.totalEaten;
    final spoiled = controller.totalSpoiled;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              centerTitle: false,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "FoodSave",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  _buildAvatar(ref),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Tappable status card → Statistics
                  GestureDetector(
                    onTap: () => context.navigateTo(const StatisticsRoute()),
                    child: _buildBentoStatus(fillPercentage, freshCount, soonCount, urgentCount),
                  ),
                  const SizedBox(height: 20),

                  // Mini stats row
                  if (eaten > 0 || spoiled > 0)
                    Row(
                      children: [
                        _miniStatCard("$eaten", "Съедено", AppColors.fresh),
                        const SizedBox(width: 12),
                        _miniStatCard("$spoiled", "Выброшено", AppColors.accent),
                      ],
                    ),
                  if (eaten > 0 || spoiled > 0) const SizedBox(height: 24),

                  _buildSectionHeader(
                    title: "Срочно приготовить", 
                    onTap: () => context.navigateTo(const FridgeRoute()),
                  ),
                  const SizedBox(height: 16),
                  _buildExpiringHorizontalList(urgentProducts),
                  const SizedBox(height: 32),

                  _buildScanAction(context),
                  const SizedBox(height: 32),

                  _buildSectionHeader(
                    title: "AI Рекомендации", 
                    onTap: () => context.navigateTo(const RecipesRoute()),
                  ),
                  const SizedBox(height: 16),
                  _buildAIRecipeCard(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI КОМПОНЕНТЫ ---

  Widget _buildAvatar(WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    return profileAsync.when(
      data: (profile) => Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10)],
          image: profile.avatarUrl != null 
            ? DecorationImage(image: NetworkImage(profile.avatarUrl!), fit: BoxFit.cover)
            : null,
        ),
        child: profile.avatarUrl == null 
          ? const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.primary)
          : null,
      ),
      loading: () => const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => Container(
        width: 40, height: 40,
        decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
        child: const Icon(Icons.error_outline, size: 20, color: Colors.red),
      ),
    );
  }

  Widget _buildBentoStatus(double fillPercentage, int fresh, int soon, int urgent) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.2),
            blurRadius: 25,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20, top: -20,
            child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withValues(alpha: 0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Твой холодильник", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                       Text("Заполнен на ${(fillPercentage * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      _buildMiniIndicator(fresh, soon, urgent),
                    ],
                  ),
                ),
                _buildCircularProgress(fillPercentage),
              ],
            ),
          ),
          // Tap hint
          Positioned(
            bottom: 12,
            right: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Статистика", style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.4), size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniIndicator(int fresh, int soon, int urgent) {
    return Row(
      children: [
        if (urgent > 0) ...[
          _dot(AppColors.accent, "$urgent"), 
          const SizedBox(width: 12),
        ],
        if (soon > 0) ...[
           _dot(AppColors.warning, "$soon"),
           const SizedBox(width: 12),
        ],
        _dot(AppColors.fresh, "$fresh"),
      ],
    );
  }

  Widget _dot(Color color, String count) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCircularProgress(double value) {
    return SizedBox(
      width: 80, height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value, 
            strokeWidth: 8, 
            backgroundColor: Colors.white10, 
            color: AppColors.primary, 
            strokeCap: StrokeCap.round
          ),
          Text("${(value * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildExpiringHorizontalList(List<Product> urgentProducts) {
    if (urgentProducts.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.shadow),
        ),
        child: const Text("Всё свежее! 😊", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: urgentProducts.length,
        itemBuilder: (context, index) {
          final product = urgentProducts[index];
          final color = product.freshnessStatus == FreshnessStatus.urgent ? AppColors.accent : AppColors.warning;

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: const Offset(0, 10))],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(product.emoji, style: const TextStyle(fontSize: 40)),
                const Spacer(),
                 Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.5, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                     product.daysLeft <= 0 ? "Срочно" : "Осталось: ${product.daysLeft} д.",
                     style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)
                   ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScanAction(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.navigateTo(const ScannerRoute());
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: const [
                Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
                SizedBox(width: 16),
                Text("Добавить чек", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Spacer(),
                Icon(Icons.chevron_right_rounded, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIRecipeCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.navigateTo(const RecipesRoute()),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: const Offset(0, 10))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: const Center(
                child: Text("🍽️", style: TextStyle(fontSize: 60)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Рецепты из вашего холодильника", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text("Подобраны по вашим продуктам", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textPrimary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStatCard(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.shadow)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(val, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppColors.textPrimary)),
        if (onTap != null)
           TextButton(
            onPressed: onTap, 
            child: const Text("См. все", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
          ),
      ],
    );
  }
}