import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/features/fridge/domain/models/product.dart';
import 'package:food_save/features/fridge/presentation/controllers/fridge_controller.dart';

class ProductListItem extends ConsumerWidget {
  final Product product;

  const ProductListItem({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(product.id),
        behavior: HitTestBehavior.opaque,
        background: _buildSwipeAction(
          color: AppColors.accent,
          icon: Icons.delete_outline_rounded,
          alignment: Alignment.centerLeft,
          label: "В корзину",
        ),
        secondaryBackground: _buildSwipeAction(
          color: AppColors.fresh,
          icon: Icons.check_circle_outline_rounded,
          alignment: Alignment.centerRight,
          label: "Съедено",
        ),
        confirmDismiss: (direction) async {
          final isSpoiled = direction == DismissDirection.startToEnd;
          if (isSpoiled) {
            ref
                .read(fridgeControllerProvider.notifier)
                .markAsSpoiled(product.id);
          } else {
            ref.read(fridgeControllerProvider.notifier).markAsEaten(product.id);
          }

          final actionText = isSpoiled ? 'выброшен' : 'съеден';

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} $actionText'),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              action: SnackBarAction(
                label: 'ОТМЕНИТЬ',
                textColor: Colors.white,
                onPressed: () {
                  ref
                      .read(fridgeControllerProvider.notifier)
                      .restoreProduct(product);
                },
              ),
            ),
          );

          return true;
        },
        child: _buildProductCard(context),
      ),
    );
  }

  Widget _buildSwipeAction({
    required Color color,
    required IconData icon,
    required Alignment alignment,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(24)),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context) {
    final theme = Theme.of(context);
    final status = product.freshnessStatus;
    final isUrgent =
        status == FreshnessStatus.urgent || status == FreshnessStatus.spoiled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
        border: isUrgent
            ? Border.all(color: AppColors.accent.withOpacity(0.3), width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      child: Row(
        children: [
          // Emoji
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
                child: Text(product.emoji, style: const TextStyle(fontSize: 30))),
          ),
          const SizedBox(width: 16),
          // Инфо о продукте
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  "${product.category} • Куплено ${product.purchaseDate.day}.${product.purchaseDate.month}",
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 13),
                ),
                const SizedBox(height: 8),
                _buildFreshnessIndicator(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreshnessIndicator(BuildContext context) {
    final theme = Theme.of(context);
    Color statusColor;
    String statusText;
    double progress;

    final days = product.daysLeft;

    switch (product.freshnessStatus) {
      case FreshnessStatus.spoiled:
        statusColor = theme.colorScheme.onSurface.withOpacity(0.4);
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
            Text(statusText,
                style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            Text(
                product.freshnessStatus == FreshnessStatus.spoiled
                    ? "Просрочено"
                    : "Осталось дней: $days",
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: theme.scaffoldBackgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
      ],
    );
  }
}
