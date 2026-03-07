import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_save/features/fridge/domain/models/product.dart';

/// Simple local cache for products using SharedPreferences.
class LocalStorageService {
  static const String _productsKey = 'cached_products';

  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((p) => p.toJson()).toList();
    await prefs.setString(_productsKey, jsonEncode(jsonList));
  }

  static Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_productsKey);
    if (raw == null || raw.isEmpty) return [];

    final List decoded = jsonDecode(raw);
    return decoded.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> clearProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productsKey);
  }
}
