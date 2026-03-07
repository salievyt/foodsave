import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

enum FreshnessStatus {
  fresh,
  soon,
  urgent,
  spoiled,
}

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String category,
    required String emoji,
    required DateTime purchaseDate,
    required DateTime expiryDate,
    @Default(false) bool isEaten,
    @Default(false) bool isSpoiled,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}

extension ProductX on Product {
  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;

  FreshnessStatus get freshnessStatus {
    if (isSpoiled || daysLeft < 0) return FreshnessStatus.spoiled;
    if (daysLeft == 0 || daysLeft == 1) return FreshnessStatus.urgent;
    if (daysLeft <= 3) return FreshnessStatus.soon;
    return FreshnessStatus.fresh;
  }
}
