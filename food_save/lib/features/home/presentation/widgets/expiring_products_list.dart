import 'package:flutter/material.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/features/fridge/domain/models/product.dart';

class ExpiringProductsList extends StatelessWidget {
  final List<Product> products;

  const ExpiringProductsList({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          final color = product.freshnessStatus == FreshnessStatus.urgent
              ? AppColors.primary
              : AppColors.warning;

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8))
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                    tag: 'product_${product.id}',
                    child: Text(product.emoji, style: const TextStyle(fontSize: 40))),
                const Spacer(),
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                      product.daysLeft <= 0
                          ? "Срочно"
                          : "${product.daysLeft} дн. осталось",
                      style: TextStyle(
                          color: color, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
