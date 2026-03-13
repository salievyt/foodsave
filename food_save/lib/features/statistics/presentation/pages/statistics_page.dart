import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/features/fridge/presentation/controllers/fridge_controller.dart';
import 'package:food_save/core/widgets/base_page.dart';
import 'package:food_save/core/utils/responsive.dart';

@RoutePage()
class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _StatisticsPageContent(ref: ref);
  }
}

class _StatisticsPageContent extends BasePage {
  final WidgetRef ref;

  const _StatisticsPageContent({required this.ref});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: const Text("Статистика"),
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: theme.colorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final products = ref.watch(fridgeControllerProvider);

    final eaten = products.where((p) => p.isEaten).length;
    final spoiled = products.where((p) => p.isSpoiled).length;
    final active = products.where((p) => !p.isEaten && !p.isSpoiled).length;
    final total = products.length;

    final efficiency = total == 0 ? 0 : (eaten / total * 100).round();
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.hPadding(context),
        vertical: 20,
      ),
      child: Column(
        children: [
          // Efficiency Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFFFF6B6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Эффективность спасения еды",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Text(
                  "$efficiency%",
                  style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: efficiency / 100,
                    child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats grid
          Row(
            children: [
              _statCard(context, "$eaten", "Съедено", "🍽️", AppColors.fresh),
              const SizedBox(width: 12),
              _statCard(context, "$spoiled", "Выброшено", "🗑️", AppColors.accent),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard(context, "$active", "В холодильнике", "🧊", AppColors.primary),
              const SizedBox(width: 12),
              _statCard(context, "$total", "Всего добавлено", "📊", AppColors.warning),
            ],
          ),
          const SizedBox(height: 24),

          // Tips section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "💡 Советы по экономии",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                _tipRow(context, "Проверяйте холодильник каждые 2-3 дня"),
                _tipRow(context, "Готовьте из продуктов, которые скоро испортятся"),
                _tipRow(context, "Покупайте меньше, но чаще — так продукты свежее"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String value, String label, String emoji, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 16),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
            Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _tipRow(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8), fontSize: 14))),
        ],
      ),
    );
  }
}
